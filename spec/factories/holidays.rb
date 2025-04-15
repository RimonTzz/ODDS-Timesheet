FactoryBot.define do
  factory :holiday do
    name { "Holiday #{rand(100)}" }
    date { "2023-01-01"}
    is_bank_holiday { true }
    is_exception { false }
    description { "Description #{rand(100)}" }
  end
end