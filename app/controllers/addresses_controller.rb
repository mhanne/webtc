class AddressesController < ApplicationController

  before_filter :authenticate_user!

  def index
    @local_addresses = BITCOIN.getaddressesbyaccount(current_user.email)
    @local_addresses.map! {|a| Address.get(a) }.select!{|a| a.is_local?}.sort_by!{|a| "#{a.label}\xff"}
    @remote_addresses = Address.remote(current_user).sort_by!(&:label)
    @page_title = t('addresses.index.title')
  end

  def show
    address = params[:id]
    @address = Address.get(address)
    @account = BITCOIN.getaccount(address)
    @transactions = BITCOIN.listtransactions(@account, 100).select do |transaction|
      transaction["address"] == address
    end
    @page_title = t('addresses.show.title', :address => @address.label_or_address)
  end

  def create
    if params[:address][:address]
      if BITCOIN.validateaddress(params[:address][:address])["isvalid"]
        @address = Address.new(:user => current_user,
                               :address => params[:address][:address],
                               :label => params[:address][:label],
                               :is_local => params[:address][:is_local])
      else
        flash[:alert] = t('addresses.create.alert_invalid_address', :address => params[:address][:address])
        return redirect_to account_path
      end
    else
      address = BITCOIN.getnewaddress(current_user.email)
      @address = Address.new(:user => current_user,
                             :address => address,
                             :label => params[:address][:label],
                             :is_local => params[:address][:is_local])
    end
    if @address.save
      flash[:notice] = t('addresses.create.notice', :address => @address.label_or_address)
      redirect_to address_path(@address.address)
    else
      flash[:alert] = t('addresses.create.alert', :address => @address.address)
      redirect_to account_path
    end
  end

  def update
    @address = Address.get(params[:id])
    if @address.new_record?
      render :action => :show
    else
      if @address.update_attribute :label, params[:address][:label]
        flash[:notice] = t('addresses.update.notice', :address => @address.label)
        redirect_to address_path(@address)
      else
        flash[:alert] = t('addresses.update.alert', :address => params[:id])
        render :action => :show
      end
    end
  end

end
