class AddAncestryCacheToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :ancestry_depth, :integer, default: 0
    Account.rebuild_depth_cache!
  end
end
