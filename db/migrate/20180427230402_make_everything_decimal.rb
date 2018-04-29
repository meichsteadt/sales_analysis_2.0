class MakeEverythingDecimal < ActiveRecord::Migration[5.0]
  def change
    remove_column :customer_groups, :sales_year, :float
    remove_column :customer_products, :sales_year, :float
    remove_column :customers, :sales_year, :float
    remove_column :groups, :sales_year, :float
    remove_column :products, :sales_year, :float
    remove_column :user_groups, :sales_year, :float
    remove_column :user_products, :sales_year, :float
    remove_column :users, :sales_year, :float

    remove_column :customer_groups, :prev_sales_year, :float
    remove_column :customer_products, :prev_sales_year, :float
    remove_column :customers, :prev_sales_year, :float
    remove_column :groups, :prev_sales_year, :float
    remove_column :products, :prev_sales_year, :float
    remove_column :user_groups, :prev_sales_year, :float
    remove_column :user_products, :prev_sales_year, :float
    remove_column :users, :prev_sales_year, :float

    remove_column :customer_groups, :sales_ytd, :float
    remove_column :customer_products, :sales_ytd, :float
    remove_column :customers, :sales_ytd, :float
    remove_column :groups, :sales_ytd, :float
    remove_column :products, :sales_ytd, :float
    remove_column :user_groups, :sales_ytd, :float
    remove_column :user_products, :sales_ytd, :float
    remove_column :users, :sales_ytd, :float

    remove_column :customer_groups, :prev_sales_ytd, :float
    remove_column :customer_products, :prev_sales_ytd, :float
    remove_column :customers, :prev_sales_ytd, :float
    remove_column :groups, :prev_sales_ytd, :float
    remove_column :products, :prev_sales_ytd, :float
    remove_column :user_groups, :prev_sales_ytd, :float
    remove_column :user_products, :prev_sales_ytd, :float
    remove_column :users, :prev_sales_ytd, :float

    remove_column :customer_groups, :growth, :float
    remove_column :customer_products, :growth, :float
    remove_column :customers, :growth, :float
    remove_column :groups, :growth, :float
    remove_column :products, :growth, :float
    remove_column :user_groups, :growth, :float
    remove_column :user_products, :growth, :float
    remove_column :users, :growth, :float

    add_column :customer_groups, :sales_year, :decimal
    add_column :customer_products, :sales_year, :decimal
    add_column :customers, :sales_year, :decimal
    add_column :groups, :sales_year, :decimal
    add_column :products, :sales_year, :decimal
    add_column :user_groups, :sales_year, :decimal
    add_column :user_products, :sales_year, :decimal
    add_column :users, :sales_year, :decimal

    add_column :customer_groups, :prev_sales_year, :decimal
    add_column :customer_products, :prev_sales_year, :decimal
    add_column :customers, :prev_sales_year, :decimal
    add_column :groups, :prev_sales_year, :decimal
    add_column :products, :prev_sales_year, :decimal
    add_column :user_groups, :prev_sales_year, :decimal
    add_column :user_products, :prev_sales_year, :decimal
    add_column :users, :prev_sales_year, :decimal

    add_column :customer_groups, :sales_ytd, :decimal
    add_column :customer_products, :sales_ytd, :decimal
    add_column :customers, :sales_ytd, :decimal
    add_column :groups, :sales_ytd, :decimal
    add_column :products, :sales_ytd, :decimal
    add_column :user_groups, :sales_ytd, :decimal
    add_column :user_products, :sales_ytd, :decimal
    add_column :users, :sales_ytd, :decimal

    add_column :customer_groups, :prev_sales_ytd, :decimal
    add_column :customer_products, :prev_sales_ytd, :decimal
    add_column :customers, :prev_sales_ytd, :decimal
    add_column :groups, :prev_sales_ytd, :decimal
    add_column :products, :prev_sales_ytd, :decimal
    add_column :user_groups, :prev_sales_ytd, :decimal
    add_column :user_products, :prev_sales_ytd, :decimal
    add_column :users, :prev_sales_ytd, :decimal

    add_column :customer_groups, :growth, :decimal
    add_column :customer_products, :growth, :decimal
    add_column :customers, :growth, :decimal
    add_column :groups, :growth, :decimal
    add_column :products, :growth, :decimal
    add_column :user_groups, :growth, :decimal
    add_column :user_products, :growth, :decimal
    add_column :users, :growth, :decimal

    remove_column :sales_numbers, :sales, :float
    add_column :sales_numbers, :sales, :decimal

    remove_column :orders, :total, :float
    add_column :orders, :total, :decimal
    remove_column :orders, :price, :float
    add_column :orders, :price, :decimal
  end
end
