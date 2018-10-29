class User < ApplicationRecord
  has_many :properties, dependent: :delete_all
  has_many :renting_contracts, dependent: :delete_all
  has_many :tenants, through: :renting_contracts, dependent: :delete_all

  validates :name, presence: {message: 'name must be present for an owner'}
  validates :email, presence: {message: 'email must be present for an owner'}
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "'%{value}' is not a valid email format" }
  #validates :email, uniqueness: true

  self.per_page = 8
end
