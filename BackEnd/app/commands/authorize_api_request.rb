class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(collection = {})
    @collection = collection
  end

  def call
    admin
  end

  private

  attr_reader :params

  def admin
    @admin ||= Admin.find(decoded_auth_token[:user_id]) if decoded_auth_token
    @admin || errors.add(:token, 'Invalid token') && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_token)
  end

  def http_auth_token
    if @collection[:access_token].present?
      return @collection[:access_token]
    else
      errors.add(:token, 'Missing token')
    end
    nil
  end
end