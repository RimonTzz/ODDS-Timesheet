class User < ApplicationRecord
  self.primary_key = "user_id"

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable


  enum :role, { super_admin: 0, admin: 1, user: 2 }

  has_many :timesheets
end
