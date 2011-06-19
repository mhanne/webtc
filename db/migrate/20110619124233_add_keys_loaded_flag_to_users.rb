class AddKeysLoadedFlagToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :keys_loaded, :boolean, :default => true
  end

  def self.down
    remove_column :users, :keys_loaded
  end
end
