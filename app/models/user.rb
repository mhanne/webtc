class User < ActiveRecord::Base

  has_many :addresses

  DEFAULT_SETTINGS = {
    :language => "en",
    :units => "BTC",
  }

  LANGUAGES = [
               ["English", "en"],
               ["German", "de"],
              ]
  
  UNITS = {
    "BTC"  => 1,
    "mBTC" => 1_000,
    "uBTC" => 1_000_000,
    "satoshi" => 100_000_000,
  }


  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  before_create :check_bitcoin_account
  after_create :create_bitcoin_address
  before_update :check_address_not_changed

  serialize :settings, Hash

  def check_bitcoin_account
    if BITCOIN.getaddressesbyaccount(email).size > 0
      errors.add("email", :taken)
      return false
    end
  end

  def create_bitcoin_address
    address = BITCOIN.getaccountaddress(email)
    Address.create(:user => self, :address => address, :label => email)
    update_attribute :address, address
  end

  def check_address_not_changed
    errors.add("email", :may_not_be_changed)  if email_changed? && email_change[0] != ""
  end

  def setting(setting)
    if settings && settings[setting.to_sym]
      settings[setting.to_sym]
    else
      DEFAULT_SETTINGS[setting.to_sym]
    end
  end

end
