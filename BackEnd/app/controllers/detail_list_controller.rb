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
      render json: {properties: user.properties.as_json, tenants: user.tenants.as_json}
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
      res = property.findExpensesBetween(DateTime.strptime(startDate, EXPENSE_DATE_FORMAT_STRING), DateTime.strptime(endDate, EXPENSE_DATE_FORMAT_STRING))
      break
    end
    render json: {res: res}
  end

end
