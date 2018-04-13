class AddProductGroupNumbers < ActiveRecord::Migration[5.0]
  def change
    add_column :user_products, :product_number, :string
    add_column :user_groups, :group_number, :string
  end
end
