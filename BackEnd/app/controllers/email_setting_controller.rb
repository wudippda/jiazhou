class EmailSettingController < ApplicationController
  PERMITTED_SETTING_PARAMS = %w(domain user_name password address port openssl_verify_mode enable_starttls_auto).map(&:to_sym)

  def get_email_setting
    @email_setting = EmailSettingHelper.get_email_setting(Rails.env)
    respond_to do |format|
      format.all { render json: @email_setting.as_json}
    end
  end

  def update_email_setting
    success = true
    env = Rails.env
    # Need to take care if the input json is malicious
    @options = JSON.parse(params.require(:options))
    @options = ActionController::Parameters.new(@options).permit(PERMITTED_SETTING_PARAMS)
    @email_setting = EmailSettingHelper.get_email_setting
    @email_setting[env].merge!(@options) if @options != nil
    Rails.logger.info(@email_setting)

    begin
      File.write(EmailSettingHelper.get_email_setting_file_path, YAML.dump(@email_setting))
    rescue StandardError => error
      Rails.logger.error("Error occurs when opening email setting file! Error message:" + error.message)
      Rails.logger.debug(error.backtrace)
      success = false
    end

    respond_to do |format|
      format.all { render json: { success: success }}
    end
  end
end
