class ExcelReport < ApplicationRecord
  validates_uniqueness_of :digest
  mount_uploader :excel, ExcelUploader
  self.per_page = 5

  before_save :update_digest

  def digest
    if excel_changed? && excel.file.present? && File.exists?(excel.file.path)
        Digest::SHA256.file(excel.file.path).hexdigest
    end
  end

  def update_digest
    self.digest = digest if excel_changed?
  end
end
