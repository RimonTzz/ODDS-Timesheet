class AddCascadeDeleteToUserProjects < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :user_projects, :projects
    add_foreign_key :user_projects, :projects, on_delete: :cascade
  end
end
