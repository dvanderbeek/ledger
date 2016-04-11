class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.belongs_to :event, index: true
      t.string :name

      t.timestamps null: false
    end
    add_foreign_key :actions, :events
  end
end
