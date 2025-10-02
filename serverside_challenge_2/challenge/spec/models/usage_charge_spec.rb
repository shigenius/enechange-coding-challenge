require 'rails_helper'

RSpec.describe UsageCharge, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:plan) }
  end

  describe 'scopes' do
    describe '.by_usage' do
      subject { described_class.by_usage(usage) }

      let(:usage) { 100 }

      let!(:usage_charge_1) { create(:usage_charge, usage_lower: 0, usage_upper: 100) }
      let!(:usage_charge_2) { create(:usage_charge, usage_lower: 100, usage_upper: 200) }
      let!(:usage_charge_3) { create(:usage_charge, usage_lower: 100, usage_upper: nil) }

      let!(:usage_charge_4) { create(:usage_charge, usage_lower: 0, usage_upper: 99) }
      let!(:usage_charge_5) { create(:usage_charge, usage_lower: 101, usage_upper: 200) }
      let!(:usage_charge_6) { create(:usage_charge, usage_lower: 101, usage_upper: nil) }
\
      it 'returns usage charges that include the specified usage' do
        expect(subject).to contain_exactly(usage_charge_1, usage_charge_2, usage_charge_3)
      end
    end
  end

  describe '#calc_charge' do
    subject { usage_charge.calc_charge(usage) }

    let(:usage_charge) { build(:usage_charge, unit_price: 19.88) }
    let(:usage) { 111 }

    it '期待される従量料金を返すこと' do
      expect(subject).to be_within(0.01).of(2206.68)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:unit_price) }
    it { should validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:usage_lower) }
    # it { should validate_numericality_of(:usage_upper).only_integer.is_greater_than(:usage_lower).allow_nil }
    describe 'usage_upper is greater than usage_lower' do
      it 'is invalid if usage_lower < usage_upper' do
        record = build(:usage_charge,
          usage_lower: 100,
          usage_upper: 101,
        )

        expect(record).to be_valid
      end

      it 'is valid if usage_upper usage_lower > usage_upper' do
        record = build(:usage_charge,
          usage_lower: 100,
          usage_upper: 99,
        )

        expect(record).to be_invalid
      end

      it 'is valid if usage_upper is usage_lower == usage_upper' do
        record = build(:usage_charge,
          usage_lower: 100,
          usage_upper: 100,
        )

        expect(record).to be_invalid
      end
    end
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
