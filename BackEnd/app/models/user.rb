class User < ApplicationRecord
  has_many :properties
  has_many :renting_contracts
  has_many :tenants, through: :renting_contracts

  validates :name, presence: {message: 'name must be present for an owner'}
  validates :email, presence: {message: 'email must be present for an owner'}
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "'%{value}' is not a valid email format" }
  validates :email, uniqueness: true

  self.per_page = 8
end
