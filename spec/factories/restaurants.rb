FactoryBot.define do
  factory :restaurant do
    sequence(:name) { |n| "Restaurant #{n}" }
    address { "123 Main St" }
    phone { "555-0100" }
  end
end
