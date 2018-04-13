class AddGroupPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :image, :string
    add_column :products, :image, :string
  end
end
