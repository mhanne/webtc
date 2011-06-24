class Address < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :address
  validates_uniqueness_of :address, :scope => :user_id
  validates_uniqueness_of :label, :scope => [:user_id, :is_local], :allow_nil => false, :allow_blank => ""

  scope :local, ->(user) { where(:user_id => user.id, :is_local => true) }
  scope :remote, ->(user) { where(:user_id => user.id, :is_local => false) }

  def self.list account
    BITCOIN.getaddressesbyaccount(account)
  end

  def self.get address
    Address.find_by_address(address) || Address.find_by_label(address) || Address.new(:address => address)
  end

  def self.valid? address
    BITCOIN.validateaddress(address)["isvalid"]
  end

  def self.mine? address
    BITCOIN.validateaddress(address)["ismine"]
  end


  def listtransactions *args
    (user || User.new).listtransactions(*args).select {|a| a["address"] == address}
  end


  def label_or_address
    label && label != "" ? label : address
  end

  def to_param
    address
  end

  def received
    (BITCOIN.getreceivedbyaddress(address) * 1e8).to_i
  end


  def unload
    privkey = BITCOIN.dumpprivkey(address)
    encrypted = GPGME.encrypt([user.email], privkey, :armor => true)
    update_attribute :key, encrypted
    BITCOIN.removeprivkey(address)
  rescue
    false
  end

  def load(password)
    privkey = GPGME.decrypt(key, :passphrase_callback => ->(*args) {
      system('stty -echo')
      io = IO.for_fd(args.last, 'w')
      io.puts(Digest::SHA1.hexdigest("webtc-#{user.email}-#{password}"))
      io.flush
      system('stty echo')
    })
    BITCOIN.importprivkey(privkey, user.email)
  rescue
    false
  end

end
