class ReportController < ApplicationController
  def index
    #UserMailer.with(receiver: User.new(id: 1, first_name:"Francis", last_name:"Zhong", email: "francis.zhong@sap.com")).incoming_email.deliver_now
  end

  def send_report
    @user = User.find(params[:user_id])
    @reportType = params[:report_type]

    if @user
      @report = generate_report(@user, @report_type)
      UserMailer.with(receiver: @user, report: @report).incoming_email.deliver_now
    end

  end

  def generate_report(user, report_type)
    #Implement report generation...
  end

end
