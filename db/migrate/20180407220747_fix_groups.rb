class FixGroups < ActiveRecord::Migration[5.0]
  def change
    remove_column :groups, :sales, :float
    add_column :groups, :sales_year, :float
    remove_column :groups, :prev_sales, :float
    add_column :groups, :prev_sales_year, :float
  end
end
