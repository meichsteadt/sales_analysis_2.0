class AddAges < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :age, :integer
    add_column :groups, :age, :integer
  end
end
