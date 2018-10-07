class ExcelReport < ApplicationRecord
  mount_uploader :excel, ExcelUploader
end
