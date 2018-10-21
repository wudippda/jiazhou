class SendEmailJob
  @queue = :send_emails

  def self.perform
    UserMailer.incoming_email(User.find_by(id: 1), '8/2017').deliver_now
  end
end