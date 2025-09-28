require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:plans).dependent(:destroy) }
  end
end
