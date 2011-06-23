require 'spec_helper'

describe Transaction do
  
  fixtures :all

  context :bitcoin do
    
    before :each do
      Kernel.silence_warnings { BITCOIN = mock(:bitcoin) }
    end

    it "should format amount" do
      BITCOIN.should_receive(:listtransactions).and_return([{"amount"=>10.00000000}])
      list = Transaction.list
      list.first["amount"].should == 1000000000
    end

    it "should format fee" do
      BITCOIN.should_receive(:listtransactions).and_return([{"fee"=>0.00100000}])
      list = Transaction.list
      list.first["fee"].should == 100000
    end

    it "should not send an unverified transaction" do
      transactions(:t1).send!.should == false
    end

    it "should send a transaction" do
      BITCOIN.should_receive(:sendfrom).with("test1@example.com", "foobar", 0.00000015).and_return("12345")
      BITCOIN.should_receive(:validateaddress).with("foobar").and_return({"isvalid" => true})
      transactions(:t2).send!.should == true
      transactions(:t2).sent?.should == true
      transactions(:t2).txid.should == "12345"
    end

  end


  context :verification do
  
    context :with_no_verifications do

      it "should be created" do
        BITCOIN.should_receive(:validateaddress).with("1234").and_return({"isvalid" => true})
        t = Transaction.create(:user_id => 1, :address => "1234", :amount => 5)
        t.verifications.size.should == 0
        t.verified?.should == true
      end
      
      it "should be verified" do
        transactions(:t6).verified?.should == true
      end

    end

    context :with_one_verification do

      it "should be created" do
        BITCOIN.should_receive(:validateaddress).with("1234").and_return({"isvalid" => true})
        t = Transaction.create(:user_id => 1, :address => "1234", :amount => 15)
        t.verifications.size.should == 1
        t.verifications.first.kind.should == "dummy"
        t.verified?.should == false
      end

      it "should not be verified if verification is not verified" do
        transactions(:t1).verified?.should == false
      end

      it "should be verified if verification is verified" do
        transactions(:t2).verified?.should == true
      end

    end

    context :with_multiple_verifications do
      
      it "should be created" do
        BITCOIN.should_receive(:validateaddress).with("1234").and_return({"isvalid" => true})
        t = Transaction.create(:user_id => 1, :address => "1234", :amount => 25)
        t.verifications.size.should == 2
        t.verifications.first.kind.should == "dummy"
        t.verifications.second.kind.should == "email"
        t.verified?.should == false
      end

      it "should not be verified if none of the verifications are verified" do
        transactions(:t3).verified?.should == false
      end

      it "should not be verified if some of the verifications are verified" do
        transactions(:t4).verified?.should == false
      end

      it "should be verified if all of the verifications are verified" do
        transactions(:t5).verified?.should == true
      end

    end

  end

end
