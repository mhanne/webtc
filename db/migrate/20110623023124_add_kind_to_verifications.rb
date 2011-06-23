class AddKindToVerifications < ActiveRecord::Migration
  def self.up
    add_column :verifications, :kind, :string
  end

  def self.down
    remove_column :verifications, :kind
  end
end
