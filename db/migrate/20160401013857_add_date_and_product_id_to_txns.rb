class AddDateAndProductIdToTxns < ActiveRecord::Migration
  def change
    add_column :txns, :date, :date
    add_index :txns, :date
    add_column :txns, :product_uuid, :string
    add_index :txns, :product_uuid
  end
end
