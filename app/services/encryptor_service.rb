class EncryptorService
  def initialize(key = Settings.secret_key_base.bytes[0..31].pack("c" * 32))
    @crypt = ActiveSupport::MessageEncryptor.new(key, digest: "base64_urlsafe")
  end

  def encrypt(value, options = {})
    @crypt.encrypt_and_sign(value, **options)
  end

  def decrypt(value, options = {})
    decrypted_value = @crypt.decrypt_and_verify(value, **options)

    # If the decrypted value is a hash, convert its keys to symbols.
    # This is necessary because the json_allow_marshal serializer primarily
    # uses JSON, which converts all hash keys to strings during serialization.
    if decrypted_value.is_a?(Hash)
      decrypted_value.deep_symbolize_keys
    else
      decrypted_value
    end
  end
end
