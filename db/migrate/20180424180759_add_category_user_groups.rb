class AddCategoryUserGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :user_groups, :category, :string
    add_column :customer_groups, :category, :string
  end
end
