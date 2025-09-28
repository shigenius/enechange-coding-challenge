FactoryBot.define do
  factory :usage_charge do
    plan
    usage_lower { rand(0..100) }
    usage_upper { usage_lower + rand(1..100) }
    unit_price { rand(10.00..50.00).round(2) }
  end
end

# == Schema Information
#
# Table name: usage_charges
#
#  id                                :bigint           not null, primary key
#  unit_price(従量料金単価(円/kWh))  :decimal(10, 2)   not null
#  usage_lower(電気使用量(kWh) 下限) :integer          not null
#  usage_upper(電気使用量(kWh) 上限) :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  plan_id                           :bigint           not null
#
# Indexes
#
#  index_usage_charges_on_plan_id                      (plan_id)
#  index_usage_charges_on_usage_lower_and_usage_upper  (usage_lower,usage_upper)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#
