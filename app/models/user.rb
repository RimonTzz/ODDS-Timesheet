class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable


  enum :role, { super_admin: 0, admin: 1, user: 2 }
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :phone_number, :string

  has_many :user_projects
  has_many :timesheets, through: :user_projects
  has_many :projects, through: :user_projects
  has_many :sites, through: :projects
end
