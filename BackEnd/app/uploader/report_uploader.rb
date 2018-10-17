class ReportUploader < CarrierWave::Uploader::Base
  storage :file
  #permissions 0666

  ARCHIVE_EXTENSIONS = %w(zip rar)
  EXCEL_EXTENSIONS = %w(xlsx xls csv)

  def extension_whitelist
    return ARCHIVE_EXTENSIONS + EXCEL_EXTENSIONS
  end

  def store_dir
    Rails.root.join("public/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}")
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  before :cache, :save_original_filename

  def save_original_filename(file)
    model.original_filename ||= file.original_filename if file.respond_to?(:original_filename)
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end