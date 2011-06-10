class AccountsController < ApplicationController

  before_filter :authenticate_user!, :except => :index

  def index
    redirect_to :action => :show  if current_user
  end

  def show
    @transactions = BITCOIN.listtransactions(current_user.email, 5).reverse
    @balance = BITCOIN.getbalance(current_user.email)
    @local_addresses = BITCOIN.getaddressesbyaccount(current_user.email).map do |address|
      Address.get(address)
    end.select {|a| a.label && a.label != "" }.sort_by!{|a| a.label || "\xff"}
    @remote_addresses = []
    @remote_addresses = Address.remote(current_user).sort_by!(&:label)
    @page_title = t('accounts.show.title')
  end

end
