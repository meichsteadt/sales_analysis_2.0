class FixNamingConventionsCustomerProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :customer_products, :product_number, :string
    remove_column :customer_products, :customer_name, :string
    remove_column :user_products, :product_number, :string
    remove_column :customer_groups, :group_number, :string
    remove_column :customer_groups, :customer_name, :string
    remove_column :user_groups, :group_number, :string

    add_column :customer_products, :number, :string
    add_column :customer_products, :name, :string
    add_column :user_products, :number, :string
    add_column :customer_groups, :number, :string
    add_column :customer_groups, :name, :string
    add_column :user_groups, :number, :string
  end
end
