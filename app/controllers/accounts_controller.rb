class AccountsController < ApplicationController

  before_filter :authenticate_user!, :except => :index

  def index
  end

  def show
    @transactions = BITCOIN.listtransactions(current_user.email, 5)
    @balance = BITCOIN.getbalance(current_user.email)
    @addresses = BITCOIN.getaddressesbyaccount(current_user.email).map do |address|
      Address.get(address)
    end.select {|a| a.label && a.label != "" }

    @page_title = "Account"
  end

end
