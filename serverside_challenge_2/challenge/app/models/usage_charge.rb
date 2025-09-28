class UsageCharge < ApplicationRecord
  belongs_to :plan

  # @param usage [Integer] 電気使用量(kWh)
  # NOTE: usage_upper = nullの場合は上限なしとみなす
  scope :by_usage, ->(usage) { where("usage_lower <= ? AND (usage_upper IS NULL OR usage_upper >= ?)", usage, usage) }
end
