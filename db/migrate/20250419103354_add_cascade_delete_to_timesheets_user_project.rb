class AddCascadeDeleteToTimesheetsUserProject < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :timesheets, :user_projects

    add_foreign_key :timesheets, :user_projects, on_delete: :cascade
  end
end
