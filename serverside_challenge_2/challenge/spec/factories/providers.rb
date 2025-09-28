FactoryBot.define do
  factory :provider do
    sequence(:name) { |n| "Provider_#{n}" }
  end
end

# == Schema Information
#
# Table name: providers
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
