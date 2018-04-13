class AddGrowth < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :growth, :float, default: 0
    add_column :products, :growth, :float, default: 0
    add_column :customers, :growth, :float, default: 0
    add_column :customer_products, :growth, :float, default: 0
    add_column :customer_groups, :growth, :float, default: 0
    add_column :user_products, :growth, :float, default: 0
    add_column :user_groups, :growth, :float, default: 0
    add_column :groups, :growth, :float, default: 0

    drop_table :groups_users
  end
end
