class AddTimeframeToVerificationRules < ActiveRecord::Migration
  def self.up
    add_column :verification_rules, :timeframe, :string
  end

  def self.down
    remove_column :verification_rules, :timeframe
  end
end
