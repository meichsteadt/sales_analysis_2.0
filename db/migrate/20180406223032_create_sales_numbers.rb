class CreateSalesNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table :sales_numbers do |t|
      t.references :numberable, polymorphic: true
      t.integer :month
      t.integer :year
      t.float :sales
    end
  end
end
