class Provider < ApplicationRecord
  has_many :plans, dependent: :destroy
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
