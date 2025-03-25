class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, format: { with: /\A[0-9]{10}\z/, message: "ต้องเป็นตัวเลข 10 หลัก" }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@odds\.team\z/, message: "ต้องเป็นอีเมล @odds.team เท่านั้น" }
  validates :password, presence: true, length: { minimum: 8 }, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/, message: "ต้องมีตัวพิมพ์ใหญ่, ตัวพิมพ์เล็ก และตัวเลข" }

  enum :role, { super_admin: 0, admin: 1, user: 2 }
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :phone_number, :string

  has_many :user_projects
  has_many :timesheets, through: :user_projects
  has_many :projects, through: :user_projects
  has_many :sites, through: :projects

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
    end
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
