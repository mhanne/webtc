class AddSentAtAndTxidToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :sent_at, :datetime
    add_column :transactions, :txid, :string
  end

  def self.down
    remove_column :transactions, :sent_at
    remove_column :transactions, :txid
  end
end
