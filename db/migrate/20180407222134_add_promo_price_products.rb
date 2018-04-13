class AddPromoPriceProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :promo_price, :float
  end
end
