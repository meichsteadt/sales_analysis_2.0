class CreateCustomerProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :customers_products do |t|
      t.integer :customer_id
      t.integer :product_id
    end
  end
end
