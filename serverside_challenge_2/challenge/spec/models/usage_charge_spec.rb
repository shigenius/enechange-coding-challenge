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
end
