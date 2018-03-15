class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :category
      t.string :number
      t.integer :group_id

      t.timestamps
    end
  end
end
