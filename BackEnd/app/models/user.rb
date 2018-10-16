class User < ApplicationRecord
  has_many :properties
  has_many :renting_contracts
  has_many :tenants, through: :renting_contracts

  validates :email, presence: {message: 'email must be present for an owner'}
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'not a valid email format' }

  self.per_page = 8
end
