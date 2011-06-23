require 'spec_helper'

describe Verification do
  
  fixtures :verifications, :transactions, :users

  include WeBTC::Application.routes.url_helpers

  before :each do
    WeBTC::Application.config.verification = {
      :code_length => 10,
      :timeout => 10,
    }
    WeBTC::Application.config.mail = {
      :from => "webtc@example.com",
    }
    @transaction_data = {:user_id => users(:u1),
      :address => "mmNBMgDpjSsPrSnZmCQ8UJr9yu6MuzVDYu",
      :amount => 1000000
    }
    @v1 = verifications(:v1)
    ActionMailer::Base.deliveries = []
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

  it "should send the verification code email" do
    I18n.locale = :en
    
    transaction = transactions(:t1)
    verification = Verification.create(:transaction => transaction)
    ActionMailer::Base.deliveries.size.should == 1
    mail = ActionMailer::Base.deliveries.first
    mail.to.first.should == users(:u1).email
    mail.subject.should == I18n.t('mail.verification.subject')
    mail.body.should == I18n.t('mail.format',
                               :greeting => I18n.t('mail.greeting',
                                                   :user => users(:u1).email),
                               :body => I18n.t('mail.verification.body',
                                          :amount => transaction.amount,
                                          :unit => users(:u1).setting(:units),
                                          :address => transaction.address,
                                          :link => verify_transaction_url(verification.secret, :host => "localhost:3000"),
                                          :code => verification.secret),
                               :salutation => I18n.t('mail.salutation'))
  end

end
