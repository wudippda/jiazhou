class User < ApplicationRecord
  has_many :properties
  has_many :renting_contracts
  has_many :tenants, through: :renting_contracts

  self.per_page = 5
end
