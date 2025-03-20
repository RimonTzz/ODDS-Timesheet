class RenameNotesToWorkDescription < ActiveRecord::Migration[8.0]
  def change
    rename_column :timesheets, :notes, :work_description
  end
end
