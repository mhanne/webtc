class Transaction < ActiveRecord::Base

  belongs_to :user
  has_many :verifications

  validates_presence_of :user
  validates_presence_of :address
  validates_presence_of :amount

  before_create :create_verifications

  def self.list *args
    BITCOIN.listtransactions(*args).map {|t| parse_transaction(t)}
  end

  def self.get id
    parse_transaction(BITCOIN.gettransaction(id))
  end

  def self.parse_transaction t
    t["amount"] = (t["amount"].to_f * 1e8).to_i; t
    t["fee"] = (t["fee"].to_f * 1e8).to_i
    t
  end

  def verified?
    !verifications.map(&:verified?).include?(false)
  end

  

  private

  def create_verifications
    user.verification_rules.each do |verification_rule|
      if amount >= verification_rule.amount
        verifications << Verification.new(:kind => verification_rule.kind)
      end
    end
  end

end
