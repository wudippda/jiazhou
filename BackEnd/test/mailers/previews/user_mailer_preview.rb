# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def send_monthly_report_email
    MonthlyReportMailer.send_monthly_report_email(User.first, '8/2017')
  end
end
