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
    @smtp_settings = YAML::load(open(File.join(Rails.root, "config", "smtp.yml")).read)[Rails.env]
    Rails.logger.debug(@smtp_settings.symbolize_keys)
    mail.delivery_method.settings.merge!(@smtp_settings.symbolize_keys)
    Rails.logger.debug(mail.delivery_method.settings)
  end

end
