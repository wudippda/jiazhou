class Tenant < ApplicationRecord
  has_one :renting_contract
  has_one :user, through: :renteing_contract
end
