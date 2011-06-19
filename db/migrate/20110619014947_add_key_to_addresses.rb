class AddKeyToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :key, :text
  end

  def self.down
    remove_column :addresses, :key
  end
end
