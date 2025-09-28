require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_many(:basic_fees).dependent(:destroy) }
    it { is_expected.to have_many(:usage_charges).dependent(:destroy) }
  end
end
