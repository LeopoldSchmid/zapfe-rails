module AdminSecurity
  class SecretCipher
    PURPOSE = "admin-mfa-secret"

    class << self
      def encrypt(value)
        encryptor.encrypt_and_sign(value, purpose: PURPOSE)
      end

      def decrypt(value)
        encryptor.decrypt_and_verify(value, purpose: PURPOSE)
      end

      private

      def encryptor
        key = Rails.application.key_generator.generate_key(PURPOSE, 32)
        ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-gcm")
      end
    end
  end
end
