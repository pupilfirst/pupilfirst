class EncryptorService
  def initialize(
    key = Rails.application.secrets.secret_key_base.bytes[0..31].pack('c' * 32)
  )
    @crypt = ActiveSupport::MessageEncryptor.new(key, digest: 'base64_urlsafe')
  end

  def encrypt(value, options = {})
    @crypt.encrypt_and_sign(value, **options)
  end

  def decrypt(value, options = {})
    @crypt.decrypt_and_verify(value, **options)
  end
end
