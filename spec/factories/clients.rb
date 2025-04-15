FactoryBot.define do
  factory :client do
    client_name { "Company the pizza" }        # random ชื่อ client
    contact_info { "contact@example.com" }       # mock ข้อมูลการติดต่อ
  end
end