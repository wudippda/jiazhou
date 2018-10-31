class ApplicationController < ActionController::API
  skip_before_action :verify_authenticity_token, raise: false
  # before_action :authenticate_request
  # attr_reader :current_user
  #
  # private
  #
  # def authenticate_request
  #   collection = request.get? ? request.params : request.cookies
  #   @current_user = AuthorizeApiRequest.call(collection).result
  #   render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  # end
end
