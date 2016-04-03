class RemoveDateFromEntries < ActiveRecord::Migration
  def change
    remove_column :entries, :date, :date
    remove_column :entries, :product_uuid, :integer
  end
end
