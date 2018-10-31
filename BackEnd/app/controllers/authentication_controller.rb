class AuthenticationController < ApplicationController
  #skip_before_action :authenticate_request
  def authenticate
    command = AuthenticateAdmin.call(params[:email], params[:password])
    if command.success?
      render json: { success: true, auth_token: command.result }
    else
      render json: { success: false, error: command.errors }, status: :unauthorized
    end
  end
end