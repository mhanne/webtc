require 'spec_helper'

describe VerificationRule do

  fixtures :all

  it "should be unique by user, amount, timeframe and kind" do
    vr = VerificationRule.new(:user_id => 1, :amount => 10, :kind => "dummy", :timeframe => "minute")
    vr.save.should == false
    vr.errors[:duplicate].should == ["duplicate"]
  end

end
