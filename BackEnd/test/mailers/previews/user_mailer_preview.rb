# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def incoming_email
    UserMailer.with(receiver: User.first).incoming_email
  end
end
