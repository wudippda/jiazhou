class Expense < ApplicationRecord
  has_one :property
  has_one :tenant
end
