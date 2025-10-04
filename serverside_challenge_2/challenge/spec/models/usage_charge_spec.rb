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

    describe '#no_overlapping_ranges' do
      let(:plan) { create(:plan) }
      let!(:existing_charge) { create(:usage_charge, plan:, usage_lower: 100, usage_upper: 200) }


      shared_examples 'invalid' do
        it '重複しているため無効であること' do
          expect(new_charge).not_to be_valid
          expect(new_charge.errors[:base]).to include('overlapping usage range exists')
        end
      end

      shared_examples 'valid' do
        it '重複していないため有効であること' do
          expect(new_charge).to be_valid
        end
      end

      context '下限が既存の範囲よりも小さく、上限が既存の下限より小さい場合（完全に離れている）' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 0, usage_upper: 99) }
        it_behaves_like 'valid'
      end

      context '下限が既存の上限よりも大きい場合（完全に離れている）' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 201, usage_upper: 300) }
        it_behaves_like 'valid'
      end

      context '別のプランに属する場合' do
        let(:new_charge) { build(:usage_charge, plan: create(:plan), usage_lower: 100, usage_upper: 200) }
        it_behaves_like 'valid'
      end

      context '完全に同じ範囲の場合' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 100, usage_upper: 200) }
        it_behaves_like 'invalid'
      end

      context '既存範囲の下端と重なる場合（[50, 100]）' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 50, usage_upper: 100) }
        it_behaves_like 'invalid'
      end

      context '既存範囲の下端を超えて部分的に重なる場合（[50, 101]）' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 50, usage_upper: 101) }
        it_behaves_like 'invalid'
      end

      context '既存範囲の上端と重なる場合（[200, 250]）' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 200, usage_upper: 250) }
        it_behaves_like 'invalid'
      end

      context '既存範囲の上端を超えて部分的に重なる場合（[199, 250]）' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 199, usage_upper: 250) }
        it_behaves_like 'invalid'
      end

      context '既存範囲の中に完全に含まれる場合（[120, 180]）' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 120, usage_upper: 180) }
        it_behaves_like 'invalid'
      end

      context '既存の usage_upper が nil（上限なし）の場合' do
        let!(:existing_charge) { create(:usage_charge, plan:, usage_lower: 100, usage_upper: nil) }

        context '下限・上限ともに既存範囲より小さい場合（重複なし）' do
          let(:new_charge) { build(:usage_charge, plan:, usage_lower: 50, usage_upper: 99) }
          it_behaves_like 'valid'
        end

        context '既存範囲の下端と一致する場合（[50, 100]）' do
          let(:new_charge) { build(:usage_charge, plan:, usage_lower: 50, usage_upper: 100) }
          it_behaves_like 'invalid'
        end

        context '下限が既存範囲内にある場合（[101, 1000]）' do
          let(:new_charge) { build(:usage_charge, plan:, usage_lower: 101, usage_upper: 1000) }
          it_behaves_like 'invalid'
        end

        context '上限が存在せず下限が既存範囲より小さい場合（[99, nil]）' do
          let(:new_charge) { build(:usage_charge, plan:, usage_lower: 99, usage_upper: nil) }
          it_behaves_like 'invalid'
        end

        context '上限が存在せず下限が一致する場合（[100, nil]）' do
          let(:new_charge) { build(:usage_charge, plan:, usage_lower: 100, usage_upper: nil) }
          it_behaves_like 'invalid'
        end

        context '上限が存在せず下限が既存範囲より少し大きい場合（[101, nil]）' do
          let(:new_charge) { build(:usage_charge, plan:, usage_lower: 101, usage_upper: nil) }
          it_behaves_like 'invalid'
        end
      end

      context '新しい usage_upper が nil（上限なし）の場合' do
        let(:new_charge) { build(:usage_charge, plan:, usage_lower: 150, usage_upper: nil) }

        context '既存範囲が完全に下側にある場合（[100, 149]）' do
          let!(:existing_charge) { create(:usage_charge, plan:, usage_lower: 100, usage_upper: 149) }
          it_behaves_like 'valid'
        end

        context '下限が既存範囲の下端と一致する場合（[150, 151]）' do
          let!(:existing_charge) { create(:usage_charge, plan:, usage_lower: 150, usage_upper: 151) }
          it_behaves_like 'invalid'
        end

        context '下限が既存範囲のすぐ上にある場合（[151, 152]）' do
          let!(:existing_charge) { create(:usage_charge, plan:, usage_lower: 151, usage_upper: 152) }
          it_behaves_like 'invalid'
        end

        context '既存の usage_upper が nil で範囲が重なる場合（[149, nil]）' do
          let!(:existing_charge) { create(:usage_charge, plan:, usage_lower: 149, usage_upper: nil) }
          it_behaves_like 'invalid'
        end

        context '既存の usage_upper が nil で下限が一致する場合（[150, nil]）' do
          let!(:existing_charge) { create(:usage_charge, plan:, usage_lower: 150, usage_upper: nil) }
          it_behaves_like 'invalid'
        end

        context '既存の usage_upper が nil で下限が既存範囲より大きい場合（[151, nil]）' do
          let!(:existing_charge) { create(:usage_charge, plan:, usage_lower: 151, usage_upper: nil) }
          it_behaves_like 'invalid'
        end
      end
    end

    describe 'usage_upper is greater than usage_lower' do
      it 'is valid if usage_lower < usage_upper' do
        record = build(:usage_charge,
          usage_lower: 100,
          usage_upper: 101,
        )

        expect(record).to be_valid
      end

      it 'is invalid if usage_upper usage_lower > usage_upper' do
        record = build(:usage_charge,
          usage_lower: 100,
          usage_upper: 99,
        )

        expect(record).to be_invalid
      end

      it 'is invalid if usage_upper is usage_lower == usage_upper' do
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
#  index_usage_charges_on_plan_id                                  (plan_id)
#  index_usage_charges_on_plan_id_and_usage_lower_and_usage_upper  (plan_id,usage_lower,usage_upper)
#  index_usage_charges_on_usage_lower_and_usage_upper              (usage_lower,usage_upper)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#
