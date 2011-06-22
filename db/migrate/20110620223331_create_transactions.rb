class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|

      t.integer :user_id
      t.string :address
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
