# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def incoming_email
    UserMailer.incoming_email(User.first, '8/2017')
  end
end
