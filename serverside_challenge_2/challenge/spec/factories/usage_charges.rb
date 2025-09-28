FactoryBot.define do
  factory :usage_charge do
    plan
    usage_lower { rand(0..100) }
    usage_upper { usage_lower + rand(1..100) }
    unit_price { rand(10.00..50.00).round(2) }
  end
end
