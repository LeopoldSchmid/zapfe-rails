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

module AdminAuthenticationTestHelper
  def sign_in_admin(admin_user, password: ADMIN_TEST_PASSWORD, role: "owner")
    ApplicationController::RATE_LIMIT_STORE.clear
    admin_user.update_columns(role: role, active: true)

    post admin_login_url, params: { email: admin_user.email, password: password }
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
