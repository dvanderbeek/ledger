class AddTxnIdToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :txn_id, :integer
    add_index :entries, :txn_id
    add_foreign_key :entries, :txns
  end
end
