class UserProject < ApplicationRecord
  belongs_to :user
  belongs_to :project

  has_many :timesheets, foreign_key: "user_project_id", dependent: :destroy

  enum :position, {
    'Scrum Master': 0,
    'Software Developer': 1,
    'Business Analyst': 2,
    'Quality Assurance': 3,
    'Technical Coach': 4,
    'User Experience / User Interface Designer': 5
  }

  validates :position, presence: true
  validates :user_id, presence: true
end
