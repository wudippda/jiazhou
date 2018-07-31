class Tenant < ApplicationRecord
  has_one :renting_contract
  has_many :expenses
end
