module EmailSettingHelper

  def self.get_email_setting_file_path
    return File.join(Rails.root, "config", "smtp.yml")
  end

  def self.get_email_setting(env = nil)
    config_file_path = get_email_setting_file_path
    # when env is nil, return full settings
    return env == nil ? YAML.load_file(config_file_path) : YAML.load_file(config_file_path)[env]
  end

end