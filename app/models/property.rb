class Property < ApplicationRecord
  belongs_to :user
  belongs_to :renting_contract
end
