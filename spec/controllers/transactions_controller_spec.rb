require 'spec_helper'

describe TransactionsController do
  
  include Devise::TestHelpers

  fixtures :all

  before :each do
    silence_warnings { BITCOIN = mock(:bitcoin) }
    @user = User.find(1)
    sign_in @user
  end

  context :parse_amount do

    it "should parse amount when creating transaction" do
      BITCOIN.should_receive(:getbalance).with(@user.email).and_return(0)
      post :create, :transaction => { :address => "foobar", :amount => "123" }
      assigns(:transaction).amount.should == 12300000
    end

    it "should parse simple values" do
      controller.instance_eval { parse_amount("1") }.should == 100000
      controller.instance_eval { parse_amount("1234") }.should == 123400000
      controller.instance_eval { parse_amount("1005") }.should == 100500000
    end

    it "should parse floats" do
      controller.instance_eval { parse_amount("1.5") }.should == 150000
      controller.instance_eval { parse_amount("1000.50") }.should == 100050000
    end

    it "should interpret , as ." do
      controller.instance_eval { parse_amount("1,234") }.should == 123400
      controller.instance_eval { parse_amount("1,234.5") }.should == 123400
    end

    it "should use the first point if there are multiple" do
      controller.instance_eval { parse_amount("1.23.4") }.should == 123000
      controller.instance_eval { parse_amount("0.123.4") }.should == 12300
      controller.instance_eval { parse_amount("1.234.567") }.should == 123400
      controller.instance_eval { parse_amount("0.000.123") }.should == 0
    end

  end

  context :create do

    it "should create a new transaction" do
      BITCOIN.should_receive(:getbalance).with(@user.email).and_return(150)
      BITCOIN.should_receive(:validateaddress).with("foobar").and_return({"isvalid" => true})
      expect do
        post :create, :transaction => { :address => "foobar", :amount => "123" }
      end.to change { Transaction.count }.by(1)
      response.should redirect_to(verify_transaction_path(assigns(:transaction)))
    end

    # it "should not create new transaction if amount exceeds balance" do
    #   BITCOIN.should_receive(:getbalance).with(@user.email).and_return(0)
    #   expect do
    #     post :create, :transaction => { :address => "foobar", :amount => "123" }
    #   end.to_not change { Transaction.count }.by(1)
    #   response.should redirect_to(account_path)
    #   flash[:alert].should == I18n.t('transactions.create.alert_insufficient_funds')
    # end

    # it "should not create new transaction with invalid address" do
    #   BITCOIN.should_receive(:getbalance).with(@user.email).and_return(150)
    #   BITCOIN.should_receive(:validateaddress).with("foobar").and_return({"isvalid" => false})
    #   expect do
    #     post :create, :transaction => { :address => "foobar", :amount => "123" }
    #   end.to_not change { Transaction.count }.by(1)
    #   response.should redirect_to(account_path)
    #   flash[:alert].should == I18n.t('transactions.create.error')
    #   assigns(:transaction).errors.should == {:address=>["invalid"]}
    # end

  end

  # context :verify do
    
  #   it "should display verification page for unverified transaction" do
  #     post :verify, :id => 1
  #     response.should be_success
  #   end

  #   it "should verify verifications with given codes posted from form" do
  #     transaction = transactions(:t3)
  #     post :verify, :id => transaction.id, :verifications => {"3" => "12345", "4" => "12345"}
  #     response.should redirect_to(commit_transaction_path(transaction))
  #     verifications(:v3).verified?.should == true
  #     verifications(:v4).verified?.should == true
  #     transaction.verified?.should == true
  #   end

  #   it "should verify a single verification passed by get" do
  #     transaction = transactions(:t1)
  #     get :verify, :id => 1, :code => "12345"
  #     response.should redirect_to(commit_transaction_path(transaction))
  #     Verification.find(1).verified?.should == true
  #     transaction.verified?.should == true
  #   end

  #   it "should redirect to commit_transaction_path for verified transaction" do
  #     transaction = transactions(:t2)
  #     post :verify, :id => transaction.id
  #     response.should redirect_to(commit_transaction_path(transaction))
  #   end

  # end

  # context :commit do
    
  #   it "should not commit an unverified transaction" do
  #     get :commit, :id => 1
  #     response.should redirect_to(verify_transaction_path(1))
  #     flash[:alert].should == I18n.t('transactions.commit.alert.not_verified')
  #     Transaction.find(1).sent?.should == false
  #     Transaction.find(1).txid.should == nil
  #   end

  #   it "should not commit a transaction that exceeds account balance" do
  #     BITCOIN.should_receive(:getbalance).with("test1@example.com").and_return(0.0)
  #     get :commit, :id => 2
  #     response.should redirect_to(account_path)
  #     flash[:alert].should == I18n.t('transactions.commit.alert.insufficient_funds')
  #     Transaction.find(2).sent?.should == false
  #     Transaction.find(2).txid.should == nil
  #   end

  #   it "should commit a proper verified transaction" do
  #     BITCOIN.should_receive(:getbalance).with("test1@example.com").and_return(100.0)
  #     BITCOIN.should_receive(:sendfrom).with("test1@example.com", "foobar", 0.00000015).and_return("testtxid")
  #     BITCOIN.should_receive(:validateaddress).with("foobar").and_return({"isvalid" => true})
  #     get :commit, :id => 2
  #     response.should redirect_to(transaction_path("testtxid"))
  #     flash[:notice].should == I18n.t('transactions.commit.notice',
  #                                     :amount => "0.00015", :address => "foobar",
  #                                     :unit => "mBTC")
  #     Transaction.find(2).sent?.should == true
  #     Transaction.find(2).txid.should == "testtxid"
  #   end

  # end


end
