module AdminSecurity
  class RecoveryCodes
    COUNT = 10

    class << self
      def generate
        Array.new(COUNT) { "#{SecureRandom.hex(4)}-#{SecureRandom.hex(4)}" }
      end

      def digest(code)
        OpenSSL::HMAC.hexdigest("SHA256", digest_key, normalize(code))
      end

      def normalize(code)
        code.to_s.downcase.gsub(/[^a-f0-9]/, "")
      end

      private

      def digest_key
        Rails.application.key_generator.generate_key("admin-mfa-recovery-code", 32)
      end
    end
  end
end
