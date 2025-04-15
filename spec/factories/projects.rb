FactoryBot.define do
  factory :project do
    sequence(:project_name) { |n| "Project #{n}" }
    site { create(:site) }
    check_in_time { "09:00" }
    check_out_time { "17:00" }
    client { create(:client) }
  end
end
