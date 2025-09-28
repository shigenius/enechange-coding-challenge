require 'rails_helper'

RSpec.describe BasicFee, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:plan) }
  end

  describe 'scopes' do
    describe '.by_ampere' do
      subject { described_class.by_ampere(ampere) }
      
      let(:ampere) { 30 }

      let!(:basic_fee_30A) { create(:basic_fee, ampere: 30) }
      let!(:basic_fee_40A) { create(:basic_fee, ampere: 40) }
      let!(:basic_fee_50A) { create(:basic_fee, ampere: 50) }

      it 'returns basic fees with the specified ampere' do
        expect(subject).to contain_exactly(basic_fee_30A)
      end
    end
  end
end
