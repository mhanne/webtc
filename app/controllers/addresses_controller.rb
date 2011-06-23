class AddressesController < ApplicationController

  before_filter :authenticate_user!, :check_bitcoin_keys

  def index
    @local_addresses = current_user.getaddresses
    @local_addresses.map! {|a| Address.get(a) }
    @local_addresses.select!{|a| a.is_local?}
    @local_addresses.sort_by!{|a| "#{a.label}\xff"}
    @remote_addresses = Address.remote(current_user).sort_by!(&:label)
    @page_title = t('addresses.index.title')
  end

  def show
    address = params[:id]
    @address = Address.get(address)
    @transactions = @address.listtransactions(100)
    @page_title = t('addresses.show.title', :address => @address.label_or_address)
  end

  def create
    if params[:address][:address]
      if Address.valid?(params[:address][:address])
        @address = Address.new(:user => current_user,
                               :address => params[:address][:address],
                               :label => params[:address][:label],
                               :is_local => params[:address][:is_local])
      else
        flash[:alert] = t('addresses.create.alert_invalid_address', :address => params[:address][:address])
        return redirect_to account_path
      end
    else
      address = current_user.getnewaddress
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
