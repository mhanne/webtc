class CreateVerificationRules < ActiveRecord::Migration
  def self.up
    create_table :verification_rules do |t|

      t.integer :user_id
      t.integer :amount
      t.string :kind

      t.timestamps
    end
  end

  def self.down
    drop_table :verification_rules
  end
end
