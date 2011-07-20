class CreateBroadcastTransactions < ActiveRecord::Migration
  def self.up
    create_table :broadcast_transactions do |t|
      t.string :txid
      t.text :rawtransaction
      t.datetime :broadcasted_at
      t.integer :tries, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :broadcast_transactions
  end
end
