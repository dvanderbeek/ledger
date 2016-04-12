class AddFromAccountToWaterfalls < ActiveRecord::Migration
  def change
    add_column :waterfalls, :from_account_id, :integer
    add_index :waterfalls, :from_account_id
  end
end
