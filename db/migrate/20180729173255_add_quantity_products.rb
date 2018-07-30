class AddQuantityProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_groups ,:quantity, :integer, default: 0
    add_column :customer_groups ,:prev_quantity, :integer, default: 0
    add_column :customer_groups ,:quantity_ytd, :integer, default: 0
    add_column :customer_groups ,:prev_quantity_ytd, :integer, default: 0
    add_column :customer_groups ,:quantity_growth, :integer, default: 0
    add_column :customer_groups ,:quantity_growth_ytd, :integer, default: 0
    add_column :customer_groups ,:growth_ytd, :decimal, default: 0

    add_column :customer_products ,:quantity, :integer, default: 0
    add_column :customer_products ,:prev_quantity, :integer, default: 0
    add_column :customer_products ,:quantity_ytd, :integer, default: 0
    add_column :customer_products ,:prev_quantity_ytd, :integer, default: 0
    add_column :customer_products ,:quantity_growth, :integer, default: 0
    add_column :customer_products ,:quantity_growth_ytd, :integer, default: 0
    add_column :customer_products ,:growth_ytd, :decimal, default: 0

    add_column :groups ,:quantity, :integer, default: 0
    add_column :groups ,:prev_quantity, :integer, default: 0
    add_column :groups ,:quantity_ytd, :integer, default: 0
    add_column :groups ,:prev_quantity_ytd, :integer, default: 0
    add_column :groups ,:quantity_growth, :integer, default: 0
    add_column :groups ,:quantity_growth_ytd, :integer, default: 0
    add_column :groups ,:growth_ytd, :decimal, default: 0

    add_column :products ,:quantity, :integer, default: 0
    add_column :products ,:prev_quantity, :integer, default: 0
    add_column :products ,:quantity_ytd, :integer, default: 0
    add_column :products ,:prev_quantity_ytd, :integer, default: 0
    add_column :products ,:quantity_growth, :integer, default: 0
    add_column :products ,:quantity_growth_ytd, :integer, default: 0
    add_column :products ,:growth_ytd, :decimal, default: 0

    add_column :user_groups ,:quantity, :integer, default: 0
    add_column :user_groups ,:prev_quantity, :integer, default: 0
    add_column :user_groups ,:quantity_ytd, :integer, default: 0
    add_column :user_groups ,:prev_quantity_ytd, :integer, default: 0
    add_column :user_groups ,:quantity_growth, :integer, default: 0
    add_column :user_groups ,:quantity_growth_ytd, :integer, default: 0
    add_column :user_groups ,:growth_ytd, :decimal, default: 0

    add_column :user_products ,:quantity, :integer, default: 0
    add_column :user_products ,:prev_quantity, :integer, default: 0
    add_column :user_products ,:quantity_ytd, :integer, default: 0
    add_column :user_products ,:prev_quantity_ytd, :integer, default: 0
    add_column :user_products ,:quantity_growth, :integer, default: 0
    add_column :user_products ,:quantity_growth_ytd, :integer, default: 0
    add_column :user_products ,:growth_ytd, :decimal, default: 0

    add_column :sales_numbers ,:quantity, :integer, default: 0

    add_column :users ,:quantity, :integer, default: 0
    add_column :users ,:prev_quantity, :integer, default: 0
    add_column :users ,:quantity_ytd, :integer, default: 0
    add_column :users ,:prev_quantity_ytd, :integer, default: 0
    add_column :users ,:quantity_growth, :integer, default: 0
    add_column :users ,:quantity_growth_ytd, :integer, default: 0
    add_column :users ,:growth_ytd, :decimal, default: 0

    add_column :customers ,:quantity, :integer, default: 0
    add_column :customers ,:prev_quantity, :integer, default: 0
    add_column :customers ,:quantity_ytd, :integer, default: 0
    add_column :customers ,:prev_quantity_ytd, :integer, default: 0
    add_column :customers ,:quantity_growth, :integer, default: 0
    add_column :customers ,:quantity_growth_ytd, :integer, default: 0
    add_column :customers ,:growth_ytd, :decimal, default: 0
  end
end
