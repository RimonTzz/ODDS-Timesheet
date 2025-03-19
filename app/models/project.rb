class Project < ApplicationRecord
  belongs_to :site
  has_many :user_projects, dependent: :destroy
  has_many :users, through: :user_projects
end
