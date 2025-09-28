FactoryBot.define do
  factory :plan do
    provider
    sequence(:name) { |n| "Plan_#{n}" }
  end
end
