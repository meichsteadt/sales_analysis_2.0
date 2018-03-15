class AddProductId < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :product_id, :integer
  end
end
