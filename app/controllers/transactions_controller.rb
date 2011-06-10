class TransactionsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    @limit = (params[:limit] || 10).to_i
    @transactions = BITCOIN.listtransactions(current_user.email, @limit).reverse
    @page_title = t('transactions.index.title')
  end

  def show
    @transaction = BITCOIN.gettransaction(params[:id])
    unless @transaction["details"].map{|d| d["account"]}.include?(current_user.email)
      return redirect_to destroy_user_session_path
    end
    @from = Address.get(@transaction["details"].find{|d| d["category"] == "send" }["address"]) rescue nil
    @to = Address.get(@transaction["details"].find{|d| d["category"] == "receive" }["address"]) rescue nil
    @page_title = t('transactions.show.title')
  end

  def create
    address = params[:transaction][:address]
    @address = Address.get(address)
    amount = params[:transaction][:amount].to_f
    if BITCOIN.getbalance(current_user.email) >= amount && @address
      redirect_to check_transaction_path(:transaction => params[:transaction])
    else
      flash[:alert] = t('transactions.create.alert_insufficient_funds')
      return redirect_to account_path
    end
  rescue
    flash[:alert] = $!.message
    return redirect_to account_path
  end

  def check
    @address = Address.get(params[:transaction][:address])
    @transaction = params[:transaction]
    @transaction[:address] = @address
    @page_title = t('transactions.check.title')
  end

  def commit
    amount = params[:transaction][:amount].to_f
    address = params[:transaction][:address]
    begin
      txid = BITCOIN.sendfrom(current_user.email, address, amount)
      flash[:notice] = t('transactions.commit.notice', :amount => amount, :address => address)
      redirect_to transaction_path(txid)
    rescue RuntimeError => e
      flash[:alert] = t('transactions.commit.alert', :error => e.message)
      redirect_to account_path
    end
  end

  def autocomplete_address
    respond_to do |format|
      format.js { render :json => Address.remote(current_user).where("label LIKE ?", "%#{params[:term]}%").map(&:label)}
    end
    
  end

end
