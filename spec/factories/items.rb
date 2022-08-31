FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name}
    description { Faker::Lorem.sentence }
    unit_price { Faker::Number.decimal(r_digits: 2) }
    merchant { nil }
  end
end
