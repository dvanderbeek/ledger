class AddProductIdToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :product_uuid, :string
    add_index :entries, :product_uuid
  end
end
