require 'spec_helper'

describe User do

  fixtures :all
  
  before :each do
    Kernel.silence_warnings { BITCOIN = mock(:bitcoin) }
    @user = users(:u1)
    @user_data = {:email => "test2@example.com", :password => "password", :password_confirmation => "password"}
  end

  it "should not create a new user when email/account exists" do
    BITCOIN.should_receive(:getaddressesbyaccount).with(@user_data[:email]).and_return(["foobar"])
    u = User.new(@user_data)
    u.save.should == false
    u.errors.keys.include?(:email).should == true
  end


  context :create do

    before :each do
      BITCOIN.should_receive(:getaddressesbyaccount).with(@user_data[:email]).and_return([])
      BITCOIN.should_receive(:getaccountaddress).with(@user_data[:email]).and_return("foobar")
    end

    it "should create a new user" do
      u = User.new(@user_data)
      u.save.should == true
    end


    it "should create a gpg key for new user" do
      u = User.create(@user_data)
      u.get_gpg_ctx.keys(u.email).size.should == 1
    end

    it "should create a bitcoin account address for new user" do
      u = User.create(@user_data)
      u.address.should == "foobar"
    end

  end

  context :update do

    it "should not update email" do
      @user.email = "test3@example.com"
      @user.save.should == false
      @user.errors.include?(:email).should == true
    end

    it "should update users password" do
      old_hash = @user.encrypted_password
      @user.password = "newpassword"
      @user.password_confirmation = "newpassword"
      @user.save
      @user.encrypted_password.should_not == old_hash
    end

  end

  context :bitcoin do

    it "should get balance" do
      BITCOIN.should_receive(:getbalance).with(@user.email).and_return(12.345)
      @user.balance.should == 1234500000
    end

    it "should get accountaddress" do
      BITCOIN.should_receive(:getaccountaddress).with(@user.email).and_return("foobar")
      @user.accountaddress.should == "foobar"
    end

  end

  context :settings do
    
    before :each do
      BITCOIN.should_receive(:getaddressesbyaccount).with(@user_data[:email]).and_return([])
      BITCOIN.should_receive(:getaccountaddress).with(@user_data[:email]).and_return("foobar")
      @user = User.create(@user_data)
    end
    
    it "should set default settings on create" do
      @user.settings.should == User::DEFAULT_SETTINGS
    end

    it "should set setting" do
      @user.settings[:language] = "de"
      @user.save.should == true
    end

    it "should get the set setting if set" do
      @user.settings[:language] = "de"
      @user.save.should == true
      @user.setting(:language).should == "de"
    end

  end

end
