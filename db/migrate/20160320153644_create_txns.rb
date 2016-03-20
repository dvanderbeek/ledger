class CreateTxns < ActiveRecord::Migration
  def change
    create_table :txns do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
