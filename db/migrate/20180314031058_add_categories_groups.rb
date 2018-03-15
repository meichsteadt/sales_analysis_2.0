class AddCategoriesGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :category, :string
  end
end
