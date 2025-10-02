class UsageCharge < ApplicationRecord
  belongs_to :plan

  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :usage_lower, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :usage_upper, numericality: { only_integer: true, greater_than: :usage_lower }, allow_nil: true

  # @param usage [Integer] 電気使用量(kWh)
  # NOTE: usage_upper = nullの場合は上限なしとみなす
  scope :by_usage, ->(usage) { where("usage_lower <= ? AND (usage_upper IS NULL OR usage_upper >= ?)", usage, usage) }

  # 従量料金 = 従量料金単価(円/kWh) × 電気使用量(kWh)
  # @param usage [Integer] 電気使用量(kWh)
  # @return [BigDecimal] 従量料金(円)
  def calc_charge(usage)
    unit_price * usage
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
