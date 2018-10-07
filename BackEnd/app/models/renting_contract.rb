class RentingContract < ApplicationRecord
  belongs_to :user
  belongs_to :tenant
  belongs_to :property, optional: true
end
