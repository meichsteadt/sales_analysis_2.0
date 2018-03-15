class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :customer_id
      t.string :invoice_id
      t.date :invoice_date
      t.integer :quantity
      t.float :price
      t.boolean :promo
      t.integer :user_id

      t.timestamps
    end
  end
end
