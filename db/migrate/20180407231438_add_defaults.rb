class AddDefaults < ActiveRecord::Migration[5.0]
  def change
    change_column :customer_groups, :sales_year, :float, :default => 0.0
    change_column :customer_groups, :prev_sales_year, :float, :default => 0.0
    change_column :customer_groups, :sales_ytd, :float, :default => 0.0
    change_column :customer_groups, :prev_sales_ytd, :float, :default => 0.0
    change_column :customer_products, :sales_year, :float, :default => 0.0
    change_column :customer_products, :prev_sales_year, :float, :default => 0.0
    change_column :customer_products, :sales_ytd, :float, :default => 0.0
    change_column :customer_products, :prev_sales_ytd, :float, :default => 0.0
    change_column :customers, :sales_year, :float, :default => 0.0
    change_column :customers, :prev_sales_year, :float, :default => 0.0
    change_column :customers, :sales_ytd, :float, :default => 0.0
    change_column :customers, :prev_sales_ytd, :float, :default => 0.0
    change_column :users, :sales_year, :float, :default => 0.0
    change_column :users, :prev_sales_year, :float, :default => 0.0
    change_column :users, :sales_ytd, :float, :default => 0.0
    change_column :users, :prev_sales_ytd, :float, :default => 0.0
    change_column :groups, :sales_year, :float, :default => 0.0
    change_column :groups, :sales_year, :float, :default => 0.0
    change_column :groups, :prev_sales_year, :float, :default => 0.0
    change_column :groups, :prev_sales_year, :float, :default => 0.0
    change_column :products, :sales_ytd, :float, :default => 0.0
    change_column :products, :sales_ytd, :float, :default => 0.0
    change_column :products, :sales_ytd, :float, :default => 0.0
    change_column :products, :sales_ytd, :float, :default => 0.0
    change_column :user_products, :prev_sales_ytd, :float, :default => 0.0
    change_column :user_products, :prev_sales_ytd, :float, :default => 0.0
    change_column :user_products, :prev_sales_ytd, :float, :default => 0.0
    change_column :user_products, :prev_sales_ytd, :float, :default => 0.0
    change_column :user_groups, :prev_sales_ytd, :float, :default => 0.0
    change_column :user_groups, :prev_sales_ytd, :float, :default => 0.0
    change_column :user_groups, :prev_sales_ytd, :float, :default => 0.0
    change_column :user_groups, :prev_sales_ytd, :float, :default => 0.0
    change_column :sales_numbers, :sales, :float, :default => 0.0
  end
end
