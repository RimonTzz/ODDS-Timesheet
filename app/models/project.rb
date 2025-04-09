class Project < ApplicationRecord
  belongs_to :site
  has_many :user_projects, dependent: :destroy
  has_many :users, through: :user_projects
  has_many :timesheets, through: :user_projects

  attribute :check_in, :time
  attribute :check_out, :time

  def destroy_with_timesheets
    transaction do
      user_projects.each do |user_project|
        user_project.timesheets.destroy_all
      end
      destroy!
    end
  end
end
