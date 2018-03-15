class CreateGroupsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :groups_users do |t|
      t.integer :group_id
      t.integer :user_id
    end
  end
end
