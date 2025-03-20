class RenameClockInOutToCheckInOut < ActiveRecord::Migration[8.0]
  def change
    rename_column :timesheets, :clock_in, :check_in
    rename_column :timesheets, :clock_out, :check_out
    change_column :timesheets, :check_in, :time
    change_column :timesheets, :check_out, :time
  end
end
