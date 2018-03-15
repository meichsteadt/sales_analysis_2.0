class AddDefaultsToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :total, :float, default: 0
    change_column :orders, :quantity, :integer, :default => 0
    change_column :orders, :price, :float, :default => 0
  end
end
