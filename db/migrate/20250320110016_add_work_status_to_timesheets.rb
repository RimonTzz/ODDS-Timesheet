class AddWorkStatusToTimesheets < ActiveRecord::Migration[8.0]
  def change
    add_column :timesheets, :work_status, :integer, default: 0
  end
end
