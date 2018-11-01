class EmailSettingController < ApplicationController
  PERMITTED_SETTING_PARAMS = %w(domain username password address port openssl_verify_mode enable_starttls_auto).map(&:to_sym)
  SENSITIVE_FIELDS = %w(username password)

  def get_email_setting
    @email_setting = EmailSettingHelper.get_email_setting(Rails.env)
    @email_setting.each { |k, v| @email_setting[k] = EncryptionHelper.decrypt(v) if v && SENSITIVE_FIELDS.include?(k)}
    render json: @email_setting.as_json
  end

  def update_email_setting
    updateSuccess = true
    env = Rails.env
    # Need to take care if the input json is malicious
    @options = JSON.parse(params.require(:options))
    @options = ActionController::Parameters.new(@options).permit(PERMITTED_SETTING_PARAMS)
    @email_setting = EmailSettingHelper.get_email_setting
    if @options != nil
      @email_setting[env].merge!(@options) do |key, oldVal, newVal|
        SENSITIVE_FIELDS.include?(key) ? EncryptionHelper.encrypt(newVal) : newVal
      end
    end
    Rails.logger.debug(@email_setting)

    begin
      File.write(EmailSettingHelper.get_email_setting_file_path, YAML.dump(@email_setting))
    rescue StandardError => error
      Rails.logger.error("Error occurs when opening email setting file! Error message:" + error.message)
      Rails.logger.debug(error.backtrace)
      updateSuccess = false
    end
    render json: { success: updateSuccess }
  end
end
