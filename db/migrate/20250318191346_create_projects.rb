class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :project_name
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end
  end
end
