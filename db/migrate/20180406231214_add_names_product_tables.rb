class AddNamesProductTables < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_products, :product_number, :string
    add_column :customer_products, :customer_name, :string
    add_column :customer_groups, :group_number, :string
    add_column :customer_groups, :customer_name, :string
  end
end
