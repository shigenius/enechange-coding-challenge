class BasicFee < ApplicationRecord
  belongs_to :plan

  # @param ampere [Integer] 契約アンペア数(A)
  scope :by_ampere, ->(ampere) { where(ampere:) }
end

# == Schema Information
#
# Table name: basic_fees
#
#  id                        :bigint           not null, primary key
#  ampere(契約アンペア数(A)) :integer          not null
#  fee(基本料金(円))         :decimal(10, 2)   not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  plan_id                   :bigint           not null
#
# Indexes
#
#  index_basic_fees_on_ampere              (ampere)
#  index_basic_fees_on_plan_id             (plan_id)
#  index_basic_fees_on_plan_id_and_ampere  (plan_id,ampere) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#
