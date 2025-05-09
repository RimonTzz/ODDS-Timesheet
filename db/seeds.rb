# db/seeds.rb

puts "🌱 Seeding admin accounts..."

superadmin_password = ENV.fetch("SUPERADMIN_PASSWORD") { "default_superadmin_password" }
admin_password = ENV.fetch("ADMIN_PASSWORD") { "default_admin_password" }

User.find_or_create_by!(email: 'superadmin@odds.team') do |user|
  user.first_name = "Super"
  user.last_name = "Admin"
  user.phone_number = "0812345678"
  user.password = superadmin_password
  user.role = 0 # assuming 0 = super_admin
end

User.find_or_create_by!(email: 'admin@odds.team') do |user|
  user.first_name = "Admin"
  user.last_name = "User"
  user.phone_number = "0898765432"
  user.password = admin_password
  user.role = 1 # assuming 1 = admin
end

puts "✅ Admin accounts created successfully."
