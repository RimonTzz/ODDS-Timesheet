class ChangeRoleTypeInUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :role, :string
    add_column :users, :role, :integer, default: 2, null: false

  end
end