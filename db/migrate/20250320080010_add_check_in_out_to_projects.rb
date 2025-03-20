class AddCheckInOutToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :check_in, :time
    add_column :projects, :check_out, :time
  end
end
