class CreateProductMix < ActiveRecord::Migration[5.0]
  def change
    create_table :product_mixes do |t|
      t.references :mixable, polymorphic: true
      t.float :dining
      t.float :bedroom
      t.float :seating
      t.float :occasional
      t.float :youth
      t.float :home
    end
  end
end
