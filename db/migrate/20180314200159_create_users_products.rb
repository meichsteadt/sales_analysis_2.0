class CreateUsersProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products_users do |t|
      t.integer :user_id
      t.integer :product_id
    end
  end
end
