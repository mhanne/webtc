require 'spec_helper'

describe Verification do
  
  fixtures :verifications, :transactions, :users

  before :each do
    WeBTC::Application.config.verification = {
      :code_length => 10,
      :timeout => 10,
    }
    @transaction_data = {:user_id => users(:u1),
      :address => "mmNBMgDpjSsPrSnZmCQ8UJr9yu6MuzVDYu",
      :amount => 1000000
    }
    @v1 = verifications(:v1)
  end

  it "should create a verification with a transaction" do
    t = Transaction.create(@transaction_data)
    t.verifications.size.should == 1
    t.verifications.first.verified?.should == false
  end

  it "should generate a code before create if none is given" do
    v = Verification.create(:transaction => transactions(:t1))
    v.code.should_not be_nil
    v.secret.size.should <= 10
    v.salt.should_not be_nil
    v.code.should == Digest::SHA1.hexdigest("#{v.salt}-#{v.secret}")
  end

  it "should not be verified unless verified_at is set" do
    verifications(:v1).verified?.should == false
  end

  it "should be verified if verified_at is set" do
    verifications(:v2).verified?.should == true
  end

  it "should not verify when given an invalid code" do
    @v1.verify!("invalid").should == false
    @v1.verified?.should == false
  end

  it "should not verify if verification timeout has expired" do
    @v1.update_attribute :created_at, Time.now - 15
    @v1.verify!("12345").should == false
    @v1.verified?.should == false
  end

  it "should verify when given a valid code before the timeout has expired" do
    @v1.update_attribute :created_at, Time.now - 5
    @v1.verify!("12345").should == true
    @v1.verified?.should == true
  end


end
