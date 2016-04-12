class AddTypeToActions < ActiveRecord::Migration
  def change
    add_column :actions, :type, :string
  end
end
