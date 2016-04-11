class AddAncestryToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :ancestry, :string
    add_index :accounts, :ancestry
  end
end
