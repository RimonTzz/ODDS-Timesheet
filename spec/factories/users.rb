FactoryBot.define do
  factory :user do
    first_name { "Admin" }
    last_name { "User" }
    phone_number { "0812345678" }
    email { "admin@odds.team" } # ตรงกับ validation ว่าต้องลงท้ายด้วย @odds.team
    password { "Password123" }  # มีพิมพ์ใหญ่ พิมพ์เล็ก และตัวเลข
    role { :admin }
  end
end
