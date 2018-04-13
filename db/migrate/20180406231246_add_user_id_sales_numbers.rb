class AddUserIdSalesNumbers < ActiveRecord::Migration[5.0]
  def change
    add_column :sales_numbers, :user_id, :integer
  end
end
