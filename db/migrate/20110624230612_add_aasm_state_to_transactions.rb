class AddAasmStateToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :aasm_state, :string
  end

  def self.down
    remove_column :transactions, :aasm_state
  end
end
