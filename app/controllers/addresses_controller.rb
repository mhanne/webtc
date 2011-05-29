class AddressesController < ApplicationController

  before_filter :authenticate_user!

  def index
    @addresses = BITCOIN.getaddressesbyaccount(current_user.email)
    @addresses.map! {|a| Address.get(a) }
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
    if @address.label
      @page_title << "#{@address.label} (#{@address.address})"  
    else
      @page_title << @address.address
    end
  end

  def create
    address = BITCOIN.getnewaddress(current_user.email)
    @address = Address.new(:user => current_user, :address => address, :label => params[:address][:label])
    if @address.save
      flash[:notice] = "Receiving address #{@address.label} created."
      redirect_to address_path(address)
    else
      flash[:alert] = "Error creating Address: #{address}"
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
