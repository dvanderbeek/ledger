class AddParentIdToTxns < ActiveRecord::Migration
  def change
    add_column :txns, :parent_id, :integer
    add_index :txns, :parent_id
  end
end
