class UserMailer < ApplicationMailer

  DEFAULT_SUBJECT = "Incoming Report for"

  # Mail configuration
  before_action { @receiver, @report = params[:receiver], params[:report] }
  after_action :set_email_configuration

  def incoming_email
    mail(to: @receiver.email, subject: generate_subject)
  end

  def generate_subject
    return "[] #{DEFAULT_SUBJECT} #{@receiver.first_name.capitalize} #{@receiver.last_name.capitalize}"
  end

  def set_email_configuration
    @email_settings = EmailSettingHelper.get_email_setting(Rails.env)
    Rails.logger.debug(@email_settings.symbolize_keys)
    mail.delivery_method.settings.merge!(@email_settings.symbolize_keys)
    Rails.logger.info(mail.delivery_method.settings)
  end

end
