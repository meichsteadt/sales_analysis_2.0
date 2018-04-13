class AddIndexes < ActiveRecord::Migration[5.0]
  def change
    change_table :products do |t|
      t.float :sales_year
      t.float :prev_sales_year
      t.float :sales_ytd
      t.float :prev_sales_ytd
      t.float :price
    end

    change_table :users do |t|
      t.float :sales_year
      t.float :prev_sales_year
      t.float :sales_ytd
      t.float :prev_sales_ytd
    end

    change_table :customers do |t|
      t.float :sales_year
      t.float :prev_sales_year
      t.float :sales_ytd
      t.float :prev_sales_ytd
    end

    change_table :groups do |t|
      t.float :sales
      t.float :prev_sales
      t.float :sales_ytd
      t.float :prev_sales_ytd
    end

    drop_table :customers_groups
    drop_table :customers_products
    drop_table :products_users

    create_table :customer_products do |t|
      t.integer :customer_id
      t.integer :product_id
      t.index :customer_id
      t.index :product_id
      t.float :sales_year
      t.float :prev_sales_year
      t.float :sales_ytd
      t.float :prev_sales_ytd
    end

    create_table :customer_groups do |t|
      t.integer :customer_id
      t.integer :group_id
      t.index :customer_id
      t.index :group_id
      t.float :sales_year
      t.float :prev_sales_year
      t.float :sales_ytd
      t.float :prev_sales_ytd
    end

    create_table :user_products do |t|
      t.integer :user_id
      t.integer :product_id
      t.index :user_id
      t.index :product_id
      t.float :sales_year
      t.float :prev_sales_year
      t.float :sales_ytd
      t.float :prev_sales_ytd
    end

    create_table :user_groups do |t|
      t.integer :user_id
      t.integer :group_id
      t.index :user_id
      t.index :group_id
      t.float :sales_year
      t.float :prev_sales_year
      t.float :sales_ytd
      t.float :prev_sales_ytd
    end

    add_index :customers, :user_id
    add_index :orders, :product_id
    add_index :orders, :customer_id
    add_index :orders, :user_id
  end
end
