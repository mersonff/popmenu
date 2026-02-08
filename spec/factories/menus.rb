FactoryBot.define do
  factory :menu do
    sequence(:name) { |n| "Menu #{n}" }
    description { "A delicious menu" }
    active { true }
    restaurant
  end
end
