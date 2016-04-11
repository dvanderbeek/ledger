class AddBalanceCentsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :balance_cents, :integer, default: 0
  end
end
