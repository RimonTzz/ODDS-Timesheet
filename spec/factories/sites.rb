FactoryBot.define do
  factory :site do
    sequence(:site_name) { |n| "Site #{n}" }
    location { "Location #{rand(100)}" }
    client { create(:client) }
  end
end
