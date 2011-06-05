class AddressesController < ApplicationController

  before_filter :authenticate_user!

  def index
    @local_addresses = BITCOIN.getaddressesbyaccount(current_user.email)
    @local_addresses.map! {|a| Address.get(a) }
    @remote_addresses = Address.remote(current_user)
    @page_title = "List Addresses"
  end

  def show
    address = params[:id]
    @address = Address.get(address)
    @account = BITCOIN.getaccount(address)
    @transactions = BITCOIN.listtransactions(@account, 100).select do |transaction|
      transaction["address"] == address
    end
    @page_title = "Show Address "
    @page_title << if @address.label && @address.label != ""
                     @address.label
                   else
                     @address.address
                   end
  end

  def create
    if params[:address][:address]
      if BITCOIN.validateaddress(params[:address][:address])["isvalid"]
        @address = Address.new(:user => current_user,
                               :address => params[:address][:address],
                               :label => params[:address][:label],
                               :is_local => params[:address][:is_local])
      else
        flash[:alert] = "Address #{params[:address][:address]} is not valid."
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
      flash[:notice] = "Receiving address #{@address.label} created."
      redirect_to address_path(@address.address)
    else
      flash[:alert] = "Error creating Address: #{@address.errors}"
      redirect_to account_path
    end
  end

  def update
    @address = Address.get(params[:id])
    if @address.new_record?
      render :action => :show
    else
      if @address.update_attribute :label, params[:address][:label]
        flash[:notice] = "Address label changed to #{@address.label}."
        redirect_to address_path(@address)
      else
        render :action => :show
      end
    end
  end

end
