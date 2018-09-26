require 'csv'

class ReportController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  PROPERTY_OWNER_NAME_LABEL = 'PROPERTY OWNER'
  PROPERTY_OWNER_EMAIL_LABEL = 'OWNER EMAIL'
  PROPERTY_OWNER_PHONE_LABEL = 'OWNER PHONE#'
  PROPERTY_ADDRESS_LABEL = 'PROPERTY ADDRESS'
  PROPERTY_LOT_LABEL = 'LOT'
  TENANT_EMAIL_LABEL = 'TENANT EMAIL'
  TENANT_NAME_LABEL = 'TENANT(S)'
  TENANT_PHONE_LABEL = 'TENANT PHONE#'
  EXPIRE_DATE_LABEL = 'LEASE EXPIRE DATE'
  DATE_FORMAT_STRING = '%m/%d/%Y'
  EMPRY_VALUE = ''

  # public apis
  def index
    #UserMailer.with(receiver: User.new(id: 1, first_name:"Francis", last_name:"Zhong", email: "francis.zhong@sap.com")).incoming_email.deliver_now
  end

  def encode(str)
    return ApplicationHelper.forceToDefaultEncoding(str)
  end

  def readTag(tag, row)
    return encode(row[tag] || EMPRY_VALUE).strip
  end

  def send_report
    @user = User.find(params[:user_id])
    @reportType = params[:report_type]

    if @user
      @report = generate_report(@user, @report_type)
      UserMailer.with(receiver: @user, report: @report).incoming_email.deliver_now
    end

    respond_to do |format|
      format.html { render 'index.html.erb'}
    end
  end

  def parse_report()
    parseSuccess = false

    CSV.foreach(File.join(Rails.root, 'sample.csv'), :headers => true, :header_converters => lambda { |h| h.try(:upcase) }) do |row|
      ownerEmail = readTag(PROPERTY_OWNER_EMAIL_LABEL, row)

      # Find user by email, if not existed, create corresponding user in DB
      @user = User.where(email: ownerEmail).first_or_create do |user|
        Rails.logger.info("User not existed, creating...")
        user.name = readTag(PROPERTY_OWNER_NAME_LABEL, row)
        user.phone_number = readTag(PROPERTY_OWNER_PHONE_LABEL, row)
      end
      # find the property by both address and lot attributes, or create one if not existed.
      @property = @user.properties.find_by(address: readTag(PROPERTY_ADDRESS_LABEL, row), lot: readTag(PROPERTY_LOT_LABEL, row))

      # remove spaces from tenant email value
      tenantEmail = encode(row[TENANT_EMAIL_LABEL].gsub(/\s+/, "").strip)
      @tenant = @user.tenants.where(tenant_email: tenantEmail).first_or_create do |tenant|
        # If tenant not existed, create it
        tenant.tenant_phone = readTag(TENANT_PHONE_LABEL, row)
        tenant.tenant_name = readTag(TENANT_NAME_LABEL, row)
      end
    end

    respond_to do |format|
      format.js { render json: {res: parseSuccess}}
    end

  end

  # private methods
  private
    def generate_report(user, report_type)
      #Implement report generation...
    end

end
