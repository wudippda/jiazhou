class Property < ApplicationRecord
  belongs_to :user
  has_many :expenses

  def findExpensesBetween(startDateTime, endDateTime)
    s = startDateTime
    e = endDateTime
    return Expense.where('property_id = ? AND date <= ? AND date >= ?', self.id, e, s).group_by(&:category) if e > s
  end

end
