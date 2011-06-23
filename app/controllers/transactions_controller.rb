class TransactionsController < ApplicationController
  
  before_filter :authenticate_user!, :check_bitcoin_keys

  def index
    @limit = (params[:limit] || 10).to_i
    @transactions = Transaction.list(current_user.email, @limit).reverse
    @page_title = t('transactions.index.title')
  end

  def show
    @transaction = Transaction.get(params[:id])
    unless @transaction["details"].map{|d| d["account"]}.include?(current_user.email)
      return redirect_to destroy_user_session_path
    end
    @from = Address.get(@transaction["details"].find{|d| d["category"] == "send" }["address"]) rescue nil
    @to = Address.get(@transaction["details"].find{|d| d["category"] == "receive" }["address"]) rescue nil
    @page_title = t('transactions.show.title')
  end

  def create
    @transaction = Transaction.new
    @transaction.user = current_user
    @transaction.address = params[:transaction][:address]
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
    if @transaction.verified?
      redirect_to commit_transaction_path(@transaction)
    end
  end

  def commit
    begin
      @transaction = Transaction.find(params[:id])
      if @transaction.verified?
        if @transaction.amount <= current_user.balance
          if @transaction.send!
            flash[:notice] = t('transactions.commit.notice')
            redirect_to transaction_path(@transaction)
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

  private
  
  def parse_amount str
    (str.to_s.gsub(",", ".").to_f * User::UNITS[current_user.setting(:units)]).to_i
  end

end
