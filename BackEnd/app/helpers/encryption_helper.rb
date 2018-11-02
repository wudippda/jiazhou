module EncryptionHelper

  @@encryter = nil
  SALT = Rails.application.secrets.encryption_salt

  def self.initEncrypter
    len = ActiveSupport::MessageEncryptor.key_len
    secret = Rails.application.secrets.secret_key_base
    key = ActiveSupport::KeyGenerator.new(secret).generate_key(SALT, len)
    @@encryter = ActiveSupport::MessageEncryptor.new(key)
  end

  def self.getEncrypter
    @@encryter || initEncrypter
  end

  def self.encrypt(plaintext)
    return getEncrypter.encrypt_and_sign(plaintext)
  end

  def self.decrypt(encrypted_data)
    return getEncrypter.decrypt_and_verify(encrypted_data)
  end
end