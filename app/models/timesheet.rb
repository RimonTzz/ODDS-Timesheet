class Timesheet < ApplicationRecord
  belongs_to :user_project, foreign_key: "user_project_id"
  has_one :user, through: :user_project
  has_one :project, through: :user_project

  validates :date, presence: true
  validates :check_in, presence: true
  validates :check_out, presence: true
  validates :work_status, presence: true

  enum :work_status, {
    "full_day": 0,
    "morning_leave": 1,
    "afternoon_leave": 2,
    "day_off": 3,
    "sick_leave": 4
  }
end
