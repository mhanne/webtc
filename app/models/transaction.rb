class Transaction < ActiveRecord::Base

  belongs_to :user
  has_many :verifications

  validates_presence_of :user
  validates_presence_of :address
  validates_presence_of :amount

  def verified?
    !verifications.map(&:verified?).include?(false)
  end

  before_create :create_verifications

  def create_verifications
    user.verification_rules.each do |verification_rule|
      if amount >= verification_rule.amount
        verifications << Verification.new(:kind => verification_rule.kind)
      end
    end
  end

end
