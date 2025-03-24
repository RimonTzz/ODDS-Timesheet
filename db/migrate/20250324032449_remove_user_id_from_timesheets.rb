class RemoveUserIdFromTimesheets < ActiveRecord::Migration[8.0]
  def change
    remove_reference :timesheets, :user, index: true, foreign_key: true
  end
end
