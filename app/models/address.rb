class Address < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :address
  validates_uniqueness_of :address, :scope => :user_id

  def self.get address
    Address.find_by_address(address) || Address.new(:address => address)
  end

  def to_param
    address
  end

end
