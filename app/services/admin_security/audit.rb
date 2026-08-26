module AdminSecurity
  class Audit
    EVENT_TYPES = %w[
      login_succeeded login_failed logout
      password_reset_requested password_changed
      admin_user_created admin_user_updated authorization_denied
      system_settings_updated
    ].freeze

    class << self
      def log(event_type:, request:, actor: nil, target: nil, metadata: {})
        raise ArgumentError, "unknown security event" unless EVENT_TYPES.include?(event_type.to_s)

        AdminSecurityEvent.create!(
          event_type: event_type,
          actor_admin_user: actor,
          target_admin_user: target,
          request_id: request&.request_id,
          ip_address_digest: address_digest(request&.remote_ip),
          user_agent_family: user_agent_family(request&.user_agent),
          metadata: sanitize(metadata)
        )
      rescue ActiveRecord::ActiveRecordError => error
        Rails.logger.error("security_audit_write_failed event=#{event_type} error=#{error.class}")
      end

      def opaque_identifier(value)
        OpenSSL::HMAC.hexdigest("SHA256", digest_key, value.to_s.downcase.strip)
      end

      private

      def address_digest(address)
        return if address.blank?

        opaque_identifier(address)
      end

      def digest_key
        Rails.application.key_generator.generate_key("admin-security-audit", 32)
      end

      def sanitize(metadata)
        metadata.to_h.slice(:changed_fields, :reason, :recovery_code).transform_values do |value|
          value.is_a?(Array) ? value.map(&:to_s).first(20) : value.to_s.first(200)
        end
      end

      def user_agent_family(user_agent)
        value = user_agent.to_s
        return "unknown" if value.blank?
        return "Firefox" if value.include?("Firefox/")
        return "Edge" if value.include?("Edg/")
        return "Chrome" if value.include?("Chrome/")
        return "Safari" if value.include?("Safari/")

        "other"
      end
    end
  end
end
