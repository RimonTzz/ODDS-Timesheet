class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable


  enum :role, { super_admin: 0, admin: 1, user: 2 }

  has_many :timesheets
  has_many :user_projects
  has_many :projects, through: :user_projects
end
