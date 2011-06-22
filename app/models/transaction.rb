class Transaction < ActiveRecord::Base

  has_many :verifications

  def verified?
    !verifications.map(&:verified?).include?(false)
  end

  before_create :create_verifications

  def create_verifications
    verifications << Verification.new
  end

end
