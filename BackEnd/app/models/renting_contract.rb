class RentingContract < ApplicationRecord
  belongs_to :user
  belongs_to :tenant

  has_one :property
end
