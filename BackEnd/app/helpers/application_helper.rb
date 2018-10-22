module ApplicationHelper

  EXPENSE_DATE_FORMAT_STRING = '%m/%Y'

  def self.csrf_required?
    return Rails.configuration.x.csrf_required
  end

  def self.forceToDefaultEncoding(str)
    str.force_encoding("UTF-8")
  end
end
