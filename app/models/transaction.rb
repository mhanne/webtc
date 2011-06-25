class Transaction < ActiveRecord::Base

  include AASM

  belongs_to :user
  has_many :verifications

  validates_presence_of :user
  validates_presence_of :address
  validates_presence_of :amount
  validate :validate_address
  
  before_create :create_verifications

  aasm_initial_state :new
  aasm_state :new
  aasm_state :verified
  aasm_state :committed

  aasm_event :verify do
    transitions :from => :new, :to => :verified, :guard => :verified?
  end

  aasm_event :commit do
    transitions :from => [:new, :verified], :to => :committed, :guard => :verified?
  end


  def self.list *args
    BITCOIN.listtransactions(*args).map {|t| parse_transaction(t)}
  end

  def self.get id
    parse_transaction(BITCOIN.gettransaction(id))
  end

  def self.parse_transaction tr
    tr["amount"] = (tr["amount"].to_f * 1e8).to_i
    tr["fee"] = (tr["fee"].to_f * 1e8).to_i
    tr
  end

  def verified?
    !verifications.map(&:verified?).include?(false)
  end

  def sent?
    !!sent_at
  end

  def send!
    return false  if sent?
    return false  unless verified?
    txid = BITCOIN.sendfrom(user.email, address, amount.to_f / 1e8)
    if txid
      update_attributes(:sent_at => Time.now, :txid => txid)
      commit!
    else
      false
    end
  end

  private

  def create_verifications
    user.verification_rules.each do |verification_rule|
      transactions = user.transactions.
        where("created_at > ?", Time.now - 1.send(verification_rule.timeframe)).
        where(:aasm_state => "committed")

      if transactions.sum(:amount) + amount >= verification_rule.amount
        verifications << Verification.new(:kind => verification_rule.kind)
      end
    end
  end

  def validate_address
    errors.add(:address, "invalid")  unless BITCOIN.validateaddress(address)["isvalid"]
  end

end
