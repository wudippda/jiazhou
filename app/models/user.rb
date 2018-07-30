class User < ApplicationRecord
  has_many :properties
  has_many :tenants
  has_many :renting_contracts, through: :tenants
end
