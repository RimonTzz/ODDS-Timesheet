class AddPositionToUserProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :user_projects, :position, :integer
  end
end
