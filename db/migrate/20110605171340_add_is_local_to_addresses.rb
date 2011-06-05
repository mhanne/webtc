class AddIsLocalToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :is_local, :boolean, :default => true
  end

  def self.down
    remove_column :addresses, :is_local
  end
end
