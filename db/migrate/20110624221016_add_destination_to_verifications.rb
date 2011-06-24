class AddDestinationToVerifications < ActiveRecord::Migration
  def self.up
    add_column :verifications, :destination, :text
  end

  def self.down
    remove_column :verifications, :destination
  end
end
