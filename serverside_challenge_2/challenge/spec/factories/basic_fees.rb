FactoryBot.define do
  factory :basic_fee do
    plan
    ampere { rand(10..60) }
    fee { rand(500.00..2000.00).round(2) }
  end
end
