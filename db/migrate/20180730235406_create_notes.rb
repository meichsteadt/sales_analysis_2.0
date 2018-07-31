class CreateNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :notes do |t|
      t.references :user
      t.references :customer
      t.text :note

      t.timestamps
    end
  end
end
