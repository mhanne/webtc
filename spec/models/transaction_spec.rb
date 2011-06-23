require 'spec_helper'

describe Transaction do
  
  fixtures :transactions, :verifications, :users

  context :verification do
    
    context :with_one_verification do

      it "should not be verified if verification is not verified" do
        transactions(:t1).verified?.should == false
      end

      it "should be verified if verification is verified" do
        transactions(:t2).verified?.should == true
      end

    end

    context :with_multiple_verifications do
      
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
