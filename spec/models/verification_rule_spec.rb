require 'spec_helper'

describe VerificationRule do

  fixtures :all

  it "should be unique by user, amount and kind" do
    vr = VerificationRule.new(:user_id => 1, :amount => 10, :kind => "dummy")
    vr.save.should == false
    vr.errors[:duplicate].should == ["duplicate"]
  end

end
