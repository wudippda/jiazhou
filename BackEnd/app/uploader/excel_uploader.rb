class ExcelUploader < CarrierWave::Uploader::Base
  storage :file
  permissions 0666
  DEFAULT_STORAGE_DIR = "public/uploads/excels"

  def extension_white_list
    %w(xlsx xls csv)
  end

  def store_dir
    return DEFAULT_STORAGE_DIR
  end

  def filename
    "something.jpg" if original_filename # This is the part where i'm trying around right now.
  end

end