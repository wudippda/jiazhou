module EmailSettingHelper

  ENCRYPTED_FIELDS = %w(user_name password)
  SMTP_AUTHENTICATION_FIELDS = %w(authentication user_name password)

  def self.get_email_setting_file_path
    return File.join(Rails.root, "config", "smtp.yml")
  end

  def self.get_full_encrypted_email_setting
    return YAML.load_file(get_email_setting_file_path)
  end

  def self.get_email_setting(env)
    config_file_path = get_email_setting_file_path
    email_setting = YAML.load_file(config_file_path)[env]
    email_setting.each { |k, v| email_setting[k] = EncryptionHelper.decrypt(v) if v && ENCRYPTED_FIELDS.include?(k)}

    # remove smtp authentication fields if not required
    email_setting.reject! { |k, v| SMTP_AUTHENTICATION_FIELDS.include?(k)} if email_setting['authentication'].blank?
    return email_setting
  end

end