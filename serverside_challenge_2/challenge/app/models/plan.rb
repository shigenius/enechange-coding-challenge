class Plan < ApplicationRecord
  belongs_to :provider
  has_many :basic_fees, dependent: :destroy
  has_many :usage_charges, dependent: :destroy
end
