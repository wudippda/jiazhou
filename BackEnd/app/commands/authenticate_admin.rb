class AuthenticateAdmin
  prepend SimpleCommand

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    JsonWebToken.encode(user_id: admin.id) if admin
  end

  private

  attr_accessor :email, :password

  def admin
    admin = Admin.find_by(email: email)
    return admin if admin && admin.authenticate(@password)
    errors.add :user_authentication, 'invalid credentials'
    # return nil if authenticate failed
    return nil
  end
end