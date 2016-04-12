class RemoveScopeBalanceToProductFromWaterfalls < ActiveRecord::Migration
  def change
    remove_column :waterfalls, :scope_balance_to_product, :boolean
  end
end
