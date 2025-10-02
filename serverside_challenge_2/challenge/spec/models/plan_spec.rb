require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_many(:basic_fees).dependent(:destroy) }
    it { is_expected.to have_many(:usage_charges).dependent(:destroy) }
  end

  describe 'scopes' do
    describe '.by_ampere_and_usage' do
      subject { described_class.by_ampere_and_usage(ampere, usage) }

      let(:plan) { create(:plan) }
      let!(:basic_fee) { create(:basic_fee, plan:, ampere: 30) }
      let!(:usage_charge) { create(:usage_charge, plan:, usage_lower: 10, usage_upper: 100) }

      context 'アンペアと使用量に該当するプランがある場合' do
        let(:ampere) { basic_fee.ampere }
        let(:usage) { usage_charge.usage_lower }

        it 'returns target plans' do
          is_expected.to include(plan)
        end
      end

      context 'アンペアに該当するものがない場合' do
        let(:ampere) { basic_fee.ampere - 1 }
        let(:usage) { usage_charge.usage_lower }

        it 'returns an empty' do
          is_expected.to be_empty
        end
      end
      context '使用料に該当するものがない場合' do
        let(:ampere) { basic_fee.ampere }
        let(:usage) { usage_charge.usage_lower - 1 }

        it 'returns an empty' do
          is_expected.to be_empty
        end
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '.plan_prices' do
    subject { described_class.plan_prices(ampere:, usage:) }

    before do
      provider1 = create(:provider, name: '東京電力エナジーパートナー')
      provider2 = create(:provider, name: '東京ガス')
      provider3 = create(:provider, name: 'Looopでんき')
      plan1 = create(:plan, name: '従量電灯B', provider: provider1)
      plan2 = create(:plan, name: 'スタンダードS', provider: provider1)
      plan3 = create(:plan, name: 'ずっとも電気1', provider: provider2)
      plan4 = create(:plan, name: 'おうちプラン', provider: provider3)
      create(:basic_fee, plan: plan1, ampere: 10, fee: 286.0)
      create(:basic_fee, plan: plan1, ampere: 30, fee: 858.00)
      create(:basic_fee, plan: plan2, ampere: 10, fee: 311.75)
      create(:basic_fee, plan: plan2, ampere: 30, fee: 935.25)
      create(:basic_fee, plan: plan3, ampere: 30, fee: 858.00)
      create(:basic_fee, plan: plan4, ampere: 10, fee: 0.00)
      create(:basic_fee, plan: plan4, ampere: 30, fee: 0.00)
      create(:usage_charge, plan: plan1, usage_lower: 0,   usage_upper: 120, unit_price: 19.88)
      create(:usage_charge, plan: plan1, usage_lower: 121, usage_upper: 300, unit_price: 26.48)
      create(:usage_charge, plan: plan1, usage_lower: 301, usage_upper: nil, unit_price: 30.57)
      create(:usage_charge, plan: plan2, usage_lower: 0,   usage_upper: 120, unit_price: 29.80)
      create(:usage_charge, plan: plan2, usage_lower: 121, usage_upper: 300, unit_price: 36.40)
      create(:usage_charge, plan: plan2, usage_lower: 301, usage_upper: nil, unit_price: 40.49)
      create(:usage_charge, plan: plan3, usage_lower: 0,   usage_upper: 120, unit_price: 23.67)
      create(:usage_charge, plan: plan3, usage_lower: 121, usage_upper: 300, unit_price: 23.88)
      create(:usage_charge, plan: plan3, usage_lower: 301, usage_upper: nil, unit_price: 26.41)
      create(:usage_charge, plan: plan4, usage_lower: 0,   usage_upper: nil, unit_price: 28.8)
    end

    context 'アンペア10A、使用量120kWhの場合' do
      let(:ampere) { 10 }
      let(:usage) { 120 }

      it 'returns correct plan prices' do
        is_expected.to match_array([
          { provider_name: '東京電力エナジーパートナー', plan_name: '従量電灯B', price: 2671 },
          { provider_name: '東京電力エナジーパートナー', plan_name: 'スタンダードS', price: 3887 },
          { provider_name: 'Looopでんき', plan_name: 'おうちプラン', price: 3456 },
        ])
      end
    end

    context 'アンペア30A、使用量120kWhの場合' do
      let(:ampere) { 30 }
      let(:usage) { 120 }

      it 'returns correct plan prices' do
          is_expected.to match_array([
            { provider_name: '東京電力エナジーパートナー', plan_name: '従量電灯B', price: 3243 },
            { provider_name: '東京電力エナジーパートナー', plan_name: 'スタンダードS', price: 4511 },
            { provider_name: '東京ガス', plan_name: 'ずっとも電気1', price: 3698 },
            { provider_name: 'Looopでんき', plan_name: 'おうちプラン', price: 3456 },
          ])
      end
    end


    context 'アンペア10A、使用量121kWhの場合' do
      let(:ampere) { 10 }
      let(:usage) { 121 }

      it 'returns correct plan prices' do
        is_expected.to match_array([
          { provider_name: '東京電力エナジーパートナー', plan_name: '従量電灯B', price: 3490 },
          { provider_name: '東京電力エナジーパートナー', plan_name: 'スタンダードS', price: 4716},
          { provider_name: 'Looopでんき', plan_name: 'おうちプラン', price: 3484 },
        ])
      end
    end

    context 'アンペア10A、使用量302kWhの場合' do
      let(:ampere) { 10 }
      let(:usage) { 302 }

      it 'returns correct plan prices' do
        is_expected.to match_array([
          { provider_name: '東京電力エナジーパートナー', plan_name: '従量電灯B', price: 9518 },
          { provider_name: '東京電力エナジーパートナー', plan_name: 'スタンダードS', price: 12539 },
          { provider_name: 'Looopでんき', plan_name: 'おうちプラン', price: 8697},
        ])
      end
    end

    context '該当するアンペアがない場合' do
      let(:ampere) { 5 }
      let(:usage) { 120 }

      it 'returns an empty array' do
        is_expected.to be_empty
      end
    end

    context '該当する使用料がない場合' do
      let(:ampere) { 30 }
      let(:usage) { -1}

      it 'returns an empty array' do
        is_expected.to be_empty
      end
    end

    describe '異常系' do
      context 'アンペアがnilの場合' do
        let(:ampere) { nil }
        let(:usage) { 120 }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context '使用量がnilの場合' do
        let(:ampere) { 30 }
        let(:usage) { nil }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'アンペアがFloatの場合' do
        let(:ampere) { 30.5 }
        let(:usage) { 120 }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context '使用量がFloatの場合' do
        let(:ampere) { 30 }
        let(:usage) { 120.5 }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '.calc_price' do
    subject { described_class.calc_price(basic_fee:, usage_charge:, usage:) }

    context '計算結果の小数点が0.5以上の場合' do
      let(:basic_fee) { create(:basic_fee, fee: 311.75) }
      let(:usage_charge) { create(:usage_charge, unit_price: 40.49) }
      let(:usage) { 351 }

      it '計算結果が正しいこと。小数点以下切り捨てであること' do
        expect(subject).to eq(14523)
      end
    end

    context '計算結果の小数点が0.5未満の場合' do
      let(:basic_fee) { create(:basic_fee, fee: 100.01) }
      let(:usage_charge) { create(:usage_charge, unit_price: 10.01) }
      let(:usage) { 10 }

      it '計算結果が正しいこと。小数点以下切り捨てであること' do
        expect(subject).to eq(200)
      end
    end
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
