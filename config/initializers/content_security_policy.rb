# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    analytics_origin = begin
      URI.parse(ENV.fetch("UMAMI_SCRIPT_URL", "")).then { |uri| "#{uri.scheme}://#{uri.host}" if uri.is_a?(URI::HTTPS) }
    rescue URI::InvalidURIError
      nil
    end

    policy.default_src :self, :https
    policy.base_uri :self
    policy.font_src :self, :https, :data
    policy.form_action :self
    policy.frame_ancestors :self
    policy.img_src :self, :https, :data
    policy.media_src :self, :https, :blob
    policy.object_src :none
    policy.script_src :self, *Array(analytics_origin)
    policy.style_src :self, :https, :unsafe_inline
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_nonce_auto = true
end
