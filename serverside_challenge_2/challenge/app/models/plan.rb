class Plan < ApplicationRecord
  belongs_to :provider
  has_many :basic_fees, dependent: :destroy
  has_many :usage_charges, dependent: :destroy

  validates :name, presence: true

  # 契約アンペア数と電気使用量に基づき、該当する料金プランの一覧を取得する
  # @param ampere [Integer] 契約アンペア数(A)
  # @param usage [Integer] 電気使用量(kWh)
  # @return [ActiveRecord::Relation<Plan>]
  scope :by_ampere_and_usage, ->(ampere, usage) do
    joins(:basic_fees, :usage_charges)
      .includes(:provider, :basic_fees, :usage_charges)
      .merge(BasicFee.by_ampere(ampere))
      .merge(UsageCharge.by_usage(usage))
      .distinct
  end

  # 契約アンペア数と電気使用量に基づき、該当する料金プランの一覧と料金を取得する
  # @param ampere [Integer] 契約アンペア数(A)
  # @param usage [Integer] 電気使用量(kWh)
  # @return [Array<Hash>] [{ provider_name: ‘Looopでんき’, plan_name: ‘おうちプラン’, price: ‘1234’ }, …]
  def self.plan_prices(ampere:, usage:)
    raise ArgumentError, 'ampere must be an Integer' unless ampere.is_a?(Integer)
    raise ArgumentError, 'usage must be an Integer' unless usage.is_a?(Integer)

    plans = self.by_ampere_and_usage(ampere, usage)
    plans.map do |plan|
      basic_fee = plan.basic_fees.first
      usage_charge = plan.usage_charges.first

      {
        provider_name: plan.provider.name,
        plan_name: plan.name,
        price: self.calc_price(basic_fee:, usage_charge:, usage:),
      }
    end
  end

  private

  # 電気料金 = ①基本料金 + ②従量料金
  # @param basic_fee [BasicFee] 基本料金オブジェクト
  # @param usage_charge [UsageCharge] 従量料金オブジェクト
  # @param usage [Integer] 電気使用量(kWh)
  # @return [Integer] 合計電気料金 (円)
  def self.calc_price(basic_fee:, usage_charge:, usage:)
    fee = basic_fee.fee
    charge = usage_charge.calc_charge(usage)
    (fee + charge).floor # TODO: 小数点以下の扱い
  end
end

# == Schema Information
#
# Table name: plans
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :bigint           not null
#
# Indexes
#
#  index_plans_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#
