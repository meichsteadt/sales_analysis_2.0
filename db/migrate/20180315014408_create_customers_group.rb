class CreateCustomersGroup < ActiveRecord::Migration[5.0]
  def change
    create_table :customers_groups do |t|
      t.integer :group_id
      t.integer :customer_id
    end
  end
end
