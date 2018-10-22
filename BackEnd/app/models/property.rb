class Property < ApplicationRecord
  belongs_to :user
  has_many :expenses

  def findExpensesBetween(startDateTime, endDateTime, groupBy)
    s = DateTime.strptime(startDateTime, ApplicationHelper::EXPENSE_DATE_FORMAT_STRING)
    e = DateTime.strptime(endDateTime, ApplicationHelper::EXPENSE_DATE_FORMAT_STRING)

    return Expense.where('property_id = ? AND date <= ? AND date >= ?', self.id, e, s).group_by(&groupBy) if e >= s
  end

end
