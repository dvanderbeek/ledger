class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.belongs_to :account, index: true
      t.decimal :amount_cents

      t.timestamps null: false
    end
    add_foreign_key :entries, :accounts
  end
end
