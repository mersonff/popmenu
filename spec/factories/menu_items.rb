FactoryBot.define do
  factory :menu_item do
    sequence(:name) { |n| "Item #{n}" }
    description { "A tasty dish" }
    price { 9.99 }
    menu
  end
end
