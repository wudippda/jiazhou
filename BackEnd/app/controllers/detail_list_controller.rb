class DetailListController < ApplicationController

  LIST_USER_SHOW_KEYS = %w(id name email phone_number created_at)

  def list_user
    results =  User.select(LIST_USER_SHOW_KEYS).page(params[:page])
    render json:{ users: results.as_json, totalPage: results.total_pages, currentPage: params[:page]}
  end

  def find_property_and_tenant_by_user
    userId = params[:userId]
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
      render json: {error: "No user found with id #{userId}"}
    end
  end

  # public apis
  def find_expenses
    res = nil
    startDate = params[:startDate]
    endDate = params[:endDate]
    userId = params[:userId]

    User.find_by(id: userId).properties.each do |property|
      res = property.findExpensesBetween(DateTime.strptime(startDate, EXPENSE_DATE_FORMAT_STRING), DateTime.strptime(endDate, EXPENSE_DATE_FORMAT_STRING), :category)
      break
    end
    render json: {res: res}
  end

end
