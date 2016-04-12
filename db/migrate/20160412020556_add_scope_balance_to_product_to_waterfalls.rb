class AddScopeBalanceToProductToWaterfalls < ActiveRecord::Migration
  def change
    add_column :waterfalls, :scope_balance_to_product, :boolean, default: true
  end
end
