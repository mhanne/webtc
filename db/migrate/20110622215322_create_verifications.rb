class CreateVerifications < ActiveRecord::Migration
  def self.up
    create_table :verifications do |t|

      t.integer :transaction_id, :nil => false
      t.string :salt, :nil => false
      t.string :code, :nil => false
      t.datetime :verified_at

      t.timestamps
    end
  end

  def self.down
    drop_table :verifications
  end
end
