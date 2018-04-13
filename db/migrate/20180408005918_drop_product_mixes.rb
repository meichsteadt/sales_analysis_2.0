class DropProductMixes < ActiveRecord::Migration[5.0]
  def change
    drop_table :product_mixes
  end
end
