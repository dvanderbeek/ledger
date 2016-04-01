class AddTypeToTxns < ActiveRecord::Migration
  def change
    add_column :txns, :type, :string
  end
end
