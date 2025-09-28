class Provider < ApplicationRecord
  has_many :plans, dependent: :destroy
end
