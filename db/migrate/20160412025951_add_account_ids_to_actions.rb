class AddAccountIdsToActions < ActiveRecord::Migration
  def change
    add_column :actions, :credit_account_id, :integer
    add_index :actions, :credit_account_id
    add_column :actions, :debit_account_id, :integer
    add_index :actions, :debit_account_id
  end
end
