class UserMailer < ApplicationMailer

  DEFAULT_SUBJECT = "Monthly Incoming & Expense Report for"

  # Mail configuration
  before_action { @receiver, @report = params[:receiver], params[:report] }
  after_action :set_email_configuration

  def incoming_email
    mail(to: @receiver.email, subject: generate_subject)
  end

  def generate_subject
    return "[NOTIFICATION] #{DEFAULT_SUBJECT} #{@receiver.name.capitalize}"
  end

  def set_email_configuration
    @email_settings = EmailSettingHelper.get_email_setting(Rails.env)
    Rails.logger.debug(@email_settings.symbolize_keys)
    mail.delivery_method.settings.merge!(@email_settings.symbolize_keys)
    Rails.logger.debug(mail.delivery_method.settings)
  end
end
