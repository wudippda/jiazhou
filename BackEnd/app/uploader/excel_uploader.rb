class ExcelUploader < CarrierWave::Uploader::Base
  storage :file
  #permissions 0666

  def extension_white_list
    %w(xlsx xls csv)
  end

  def store_dir
    Rails.root.join("public/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}")
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end