class CreateWaterfalls < ActiveRecord::Migration
  def change
    create_table :waterfalls do |t|
      t.belongs_to :action, index: true
      t.integer :order
      t.integer :from_account_id
      t.integer :to_account_id

      t.timestamps null: false
    end
    add_index :waterfalls, :from_account_id
    add_index :waterfalls, :to_account_id
    add_foreign_key :waterfalls, :actions
  end
end
