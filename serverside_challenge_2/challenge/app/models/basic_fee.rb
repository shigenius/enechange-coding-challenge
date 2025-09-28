class BasicFee < ApplicationRecord
  belongs_to :plan

  # @param ampere [Integer] 契約アンペア数(A)
  scope :by_ampere, ->(ampere) { where(ampere:) }
end
