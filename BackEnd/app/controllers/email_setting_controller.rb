class EmailSettingController < ApplicationController
  PERMITTED_SETTING_PARAMS = %w(domain authentication user_name password address port openssl_verify_mode enable_starttls_auto).map(&:to_sym)

  def get_email_setting
    @email_setting = EmailSettingHelper.get_email_setting(Rails.env)
    render json: @email_setting.reject { |k, v| k == 'password' }.as_json
  end

  def update_email_setting
    updateSuccess = true
    env = Rails.env
    # Need to take care if the input json is malicious
    @options = JSON.parse(params.require(:options))
    @options = ActionController::Parameters.new(@options).permit(PERMITTED_SETTING_PARAMS)

    # As we do not care about the original value, just getting the encrypted settings is enough
    @email_setting = EmailSettingHelper.get_full_encrypted_email_setting
    if @options != nil
      @email_setting[env].merge!(@options) do |key, oldVal, newVal|
        EmailSettingHelper::ENCRYPTED_FIELDS.include?(key) ? EncryptionHelper.encrypt(newVal) : newVal
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
