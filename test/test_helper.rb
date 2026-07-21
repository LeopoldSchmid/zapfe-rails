if ENV["COVERAGE"] == "1"
  require "simplecov"
  SimpleCov.start "rails" do
    enable_coverage :branch
    skip "/test/"
  end
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

ADMIN_TEST_PASSWORD = "correct-horse-battery-staple"
ADMIN_TEST_MFA_SECRET = "JBSWY3DPEHPK3PXP"

module AdminAuthenticationTestHelper
  def sign_in_admin(admin_user, password: ADMIN_TEST_PASSWORD, role: "owner")
    ApplicationController::RATE_LIMIT_STORE.clear
    admin_user.update_columns(
      role: role,
      active: true,
      mfa_secret_ciphertext: AdminSecurity::SecretCipher.encrypt(ADMIN_TEST_MFA_SECRET),
      mfa_recovery_code_digests: AdminSecurity::RecoveryCodes.generate.map { |code| AdminSecurity::RecoveryCodes.digest(code) },
      mfa_enabled_at: Time.current,
      mfa_last_used_at: nil
    )

    post admin_login_url, params: { email: admin_user.email, password: password }
    follow_redirect! if response.redirect? && response.location == admin_login_mfa_url
    post admin_login_mfa_url, params: { code: ROTP::TOTP.new(ADMIN_TEST_MFA_SECRET, issuer: "Zapfe Admin").now }
    assert_redirected_to admin_root_url
  end
end

class ActionDispatch::IntegrationTest
  include AdminAuthenticationTestHelper
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
