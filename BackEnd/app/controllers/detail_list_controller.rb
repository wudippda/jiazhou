class DetailListController < ApplicationController

  LIST_USER_SHOW_KEYS = %w(id name email phone_number created_at)

  def list_user
    results =  User.select(LIST_USER_SHOW_KEYS).page(params[:page])
    render json:{ users: results.as_json, totalPage: results.total_pages, currentPage: params[:page]}
  end

  def find_property_and_tenant_by_user
    userId = params[:id]
    user = User.find_by(id: userId)
    if user
      properties = user.properties
      res = Array.new

      properties.each do |property|
        contract = user.renting_contracts.where(property_id: property.id).order(expire_date: :desc).first
        res << {property: property.as_json, tenant: Tenant.find_by(id: contract.tenant_id).as_json}
      end
      render json: res
    else
      render json: {success: false, error: "No user found with id #{userId}"}
    end
  end

  # public apis
  def find_expenses
    res = Array.new
    success = false
    startDate = params[:startDate]
    endDate = params[:endDate]
    userId = params[:id]

    begin
      user = User.find_by!(id: userId)
      user.properties.each do |property|
        res = property.findExpensesBetween(DateTime.strptime(startDate, EXPENSE_DATE_FORMAT_STRING), DateTime.strptime(endDate, EXPENSE_DATE_FORMAT_STRING), :category)
        success = true
        break
      end
    rescue ActiveRecord::RecordNotFound, StandardError => e
      Rails.logger.error(e)
    end
    render json: {success: success, res: res}
  end

end
