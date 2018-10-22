class HousingReport < ApplicationRecord
  validates_uniqueness_of :digest
  mount_uploader :report, ReportUploader
  self.per_page = 5

  before_save :update_digest

  def update_digest
    if report_changed? && report.file.present? && File.exists?(report.file.path)
      self.digest = Digest::SHA256.file(report.file.path).hexdigest
    end
    return true
  end

  validates :digest, uniqueness: true
end
