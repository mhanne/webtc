class Verification < ActiveRecord::Base

  belongs_to :transaction

  before_create :generate_code
  after_create :deliver_code

  attr_accessor :secret

  scope :confirm, :conditions => {:kind => "confirm"}
  scope :deny, :conditions => {:kind => "deny"}
  scope :normal, :conditions => ["kind != ? AND kind != ?", "confirm", "deny"]

  KINDS = [:dummy, :confirm, :email, :deny]

  def verify! secret
    timeout = WeBTC::Application.config.verification[:timeout]
    return false  if created_at + timeout <= Time.now
    if Digest::SHA1.hexdigest("#{salt}-#{secret}") == code
      update_attribute :verified_at, Time.now
      unless transaction.verifications.map(&:verified?).include?("false")
        transaction.verify!
      end
      true
    else
      false
    end
  end

  def verified?
    !!verified_at
  end

  def user
    transaction.user
  end

  private

  def generate_code
    length = WeBTC::Application.config.verification[:code_length]
    self.salt = SecureRandom.base64
    @secret = (SecureRandom.random_number * (10 ** length)).to_i.to_s
    self.code ||= Digest::SHA1.hexdigest("#{self.salt}-#{@secret}")
  end

  def deliver_code
    case self.kind
    when "dummy"
      @dummy_verification_code = @secret
      logger.info "Dummy verification code: #{@secret}"
    when "confirm"
      update_attribute :destination, @secret
    when "email"
      VerificationMailer.verification_code(self).deliver
    when "deny"
      @secret = nil  # throw away the code so this will never be verified
    end
  end

end
