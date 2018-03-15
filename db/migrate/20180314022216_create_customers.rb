class CreateCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.integer :user_id
      t.string :name_id
      t.string :state

      t.timestamps
    end
  end
end
