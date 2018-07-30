class Tenant < ApplicationRecord
  has_one :renting_contract
end
