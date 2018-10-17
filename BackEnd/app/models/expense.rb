class Expense < ApplicationRecord
  belongs_to :property
  has_one :tenant

  validates_uniqueness_of :date, scope: [:property_id, :category]
  validates :cost, presence: true, allow_blank: false
end
