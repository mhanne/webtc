class TransactionsController < ApplicationController
  
  before_filter :authenticate_user!, :check_bitcoin_keys, :except => [:upload, :import]

  include ApplicationHelper
  
  def index
    @limit = (params[:limit] || 10).to_i
    @transactions = Transaction.list(current_user.email, @limit).reverse
    @page_title = t('transactions.index.title')
  end

  def show
    @transaction = Transaction.get(params[:id])
    if current_user.is_admin?
      details = @transaction["details"].first
    else
      details = @transaction["details"].find {|d| d["account"] == current_user.email}
    end
    return redirect_to destroy_user_session_path  unless details
    @type = details["category"]
    @to = Address.get(details["address"])
    @page_title = t('transactions.show.title')
  end

  def create
    @transaction = Transaction.new
    @transaction.user = current_user
    @transaction.address = Address.get(params[:transaction][:address]).address
    @transaction.amount = parse_amount(params[:transaction][:amount])
    if current_user.balance >= @transaction.amount
      if @transaction.save
        redirect_to verify_transaction_path(@transaction)
      else
        flash[:alert] = t('transactions.create.error')
        return redirect_to account_path
      end
    else
      flash[:alert] = t('transactions.create.alert_insufficient_funds')
      return redirect_to account_path
    end
  rescue
    flash[:alert] = $!.message
    puts $!
    return redirect_to account_path
  end

  def verify
    if params[:code]
      @verification = Verification.find(params[:id])
      @transaction = @verification.transaction
      if @verification && @transaction && @transaction.user == current_user
        @verification.verify!(params[:code])
      end
    else
      @transaction = Transaction.find(params[:id])
      if params[:verifications]
        params[:verifications].each do |id, code|
          verification = Verification.find(id)
          verification.verify!(code)
        end
      end
    end
    if verification = @transaction.verifications.deny.first
      flash[:alert] = t('transactions.verify.alert.denied')
      redirect_to account_path
    elsif @transaction.verified?
      redirect_to commit_transaction_path(@transaction)
    end
  end

  def commit
    begin
      @transaction = Transaction.find(params[:id])
      if @transaction.verified?
        if @transaction.amount <= current_user.balance
          if @transaction.send!
            flash[:notice] = t('transactions.commit.notice',
                               :amount => display_amount(@transaction.amount),
                               :unit => current_user.setting(:units),
                               :address => Address.get(@transaction.address).label_or_address)
            redirect_to transaction_path(@transaction.txid)
          else
            flash[:alert] = t('transactions.commit.alert.error')
            redirect_to account_path
          end
        else
          flash[:alert] = t('transactions.commit.alert.insufficient_funds')
          redirect_to account_path
        end
      else
        flash[:alert] = t('transactions.commit.alert.not_verified')
        redirect_to verify_transaction_path(@transaction)
      end
    rescue RuntimeError => e
      flash[:alert] = t('transactions.commit.alert.error')
      redirect_to account_path
    end
  end

  def autocomplete_address
    respond_to do |format|
      format.js { render :json => Address.remote(current_user).where("label LIKE ?", "%#{params[:term]}%").map(&:label)}
    end
    
  end

  def import
    if params[:transaction]
      rawtransaction = params[:transaction][:raw]  if params[:transaction][:raw]
      rawtransaction = params[:transaction][:file].read  if params[:transaction][:file]
    end
    if rawtransaction
      txid = BITCOIN.importtransaction rawtransaction
      if txid
        broadcast_transaction = BroadcastTransaction.find_or_create_by_txid(txid)
        broadcast_transaction.rawtransaction = rawtransaction
        broadcast_transaction.broadcasted_at = Time.now
        broadcast_transaction.tries += 1
        broadcast_transaction.save
        flash[:notice] = t('transactions.import.notice', :txid => txid)
        redirect_to import_transaction_path
      end
    end
    @page_title = t('transactions.import.title')
  end

end
