class CreateWaterfalls < ActiveRecord::Migration
  def change
    create_table :waterfalls do |t|
      t.belongs_to :action, index: true
      t.integer :order
      t.integer :debit_account_id
      t.integer :credit_account_id

      t.timestamps null: false
    end
    add_index :waterfalls, :debit_account_id
    add_index :waterfalls, :credit_account_id
    add_foreign_key :waterfalls, :actions
  end
end
