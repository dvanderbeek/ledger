class CreateProductBalances < ActiveRecord::Migration
  def change
    create_table :product_balances do |t|
      t.belongs_to :account, index: true
      t.date :date
      t.string :product_uuid
      t.integer :amount_cents, default: 0

      t.timestamps null: false
    end
    add_index :product_balances, :product_uuid
    add_foreign_key :product_balances, :accounts
  end
end
