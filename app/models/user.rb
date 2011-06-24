ENV['GNUPGHOME'] = WeBTC::Application.config.gpg[:home]

require 'gpgme'
require 'digest/sha1'

class User < ActiveRecord::Base

  has_many :addresses
  has_many :transactions
  has_many :verification_rules
  has_many :verifications, :through => :transactions

  DEFAULT_SETTINGS = {
    :language => "en",
    :units => "BTC",
  }

  LANGUAGES = [
               ["English", "en"],
               ["German", "de"],
              ]
  
  UNITS = {
    "BTC"  => 10000000,
    "mBTC" => 100000,
    "uBTC" => 100,
    "satoshi" => 1,
  }

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  validate :check_bitcoin_account
  validate :check_address_not_changed
  after_create :create_gpg_key, :create_bitcoin_address, :create_settings
  before_update :check_password_changed
  after_destroy :unload_keys, :remove_gpg_key

  serialize :settings, Hash

  def check_bitcoin_account
    if new_record? && BITCOIN.getaddressesbyaccount(email).size > 0
      errors.add("email", :taken)
      return false
    end
  end

  def get_gpg_ctx
    GPGME.check_version({})
    GPGME::Ctx.new
  end

  def create_gpg_key
    ctx = get_gpg_ctx
    return false  if ctx.keys(email).any?
    config = WeBTC::Application.config.gpg
    req = "<GnupgKeyParms format=\"internal\">\n" +
      "Key-Type: #{config[:key_type]}\n" +
      "Key-Length: #{config[:key_size]}\n" +
      "Subkey-Type: #{config[:subkey_type]}\n" +
      "Subkey-Length: #{config[:subkey_size]}\n" +
      "Name-Real: #{email}\n" +
      "Name-Comment: #{email}\n" +
      "Name-Email: #{email}\n" +
      "Expire-Date: 0\n" +
      "Passphrase: #{Digest::SHA1.hexdigest("webtc-#{email}-#{password}")}\n" +
      "</GnupgKeyParms>"
    ctx.genkey(req, nil, nil)
  end

  def remove_gpg_key
    ctx = get_gpg_ctx
    key = ctx.keys(email).first
    ctx.delete_key(key, true)
  rescue
    nil
  end

  def create_bitcoin_address
    address = BITCOIN.getaccountaddress(email)
    Address.create(:user => self, :address => address, :label => email)
    update_attribute :address, address
  end

  def check_address_not_changed
    errors.add("email", :may_not_be_changed)  if !new_record? && email_changed? && email_change[0] != ""
  end

  def check_password_changed
    if encrypted_password_changed?
      remove_gpg_key
      create_gpg_key
    end
  end

  def setting(setting)
    if settings && settings[setting.to_s]
      settings[setting.to_s]
    else
      DEFAULT_SETTINGS[setting.to_sym]
    end
  end

  def unit_factor
    UNITS[setting(:units)]
  end

  def create_settings
    self.settings ||= DEFAULT_SETTINGS
  end
  
  def unload_keys
    BITCOIN.getaddressesbyaccount(email).each do |addr|
      address = Address.get(addr)
      address.user = self
      address.unload
    end
    update_attribute :keys_loaded, false
  end

  def load_keys(password)
    addresses.local(self).each do |address|
      address.load(password)
    end
    update_attribute :keys_loaded, true
  end

  
  def balance
    (BITCOIN.getbalance(email) * 1e8).to_i
  end

  def accountaddress
    BITCOIN.getaccountaddress(email)
  end

  def getaddresses
    Address.list(email)
  end

  def listtransactions(*args)
    Transaction.list(email, *args)
  end

  def newaddress
    BITCOIN.getnewaddress(email)
  end

end
