class User < ApplicationRecord
  self.primary_key = "user_id" # ใช้ user_id เป็น Primary Key

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable

  # กำหนด role ให้ User (ต้องตรงกับ database)
  enum role: { super_admin: "super_admin", admin: "admin", user: "user" }

  has_many :timesheets
end