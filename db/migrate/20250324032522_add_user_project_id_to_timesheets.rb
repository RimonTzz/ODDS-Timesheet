class AddUserProjectIdToTimesheets < ActiveRecord::Migration[8.0]
  def change
    add_reference :timesheets, :user_project, index: true, foreign_key: true
  end
end
