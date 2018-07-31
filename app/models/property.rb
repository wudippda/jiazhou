class Property < ApplicationRecord
  belongs_to :user
  belongs_to :renting_contract

  has_many :expenses
end
