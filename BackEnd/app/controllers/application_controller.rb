class ApplicationController < ActionController::API
  skip_before_action :verify_authenticity_token, raise: false
  include ActionController::MimeResponds

  # before_action :authenticate_request
  # attr_reader :current_user
  #
  # private
  #
  # def authenticate_request
  #   @current_user = AuthorizeApiRequest.call(request.headers).result
  #   render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  # end

end
