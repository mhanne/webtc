class VerificationRule < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :user
  validates_presence_of :amount
  validates_presence_of :kind

  validate :unique_by_user_and_amount_and_kind

  def unique_by_user_and_amount_and_kind
    if VerificationRule.where(:user_id => user_id,
                              :amount => amount,
                              :kind => kind).count > 0
      errors.add(:duplicate, "duplicate")
    end
  end
  
end
