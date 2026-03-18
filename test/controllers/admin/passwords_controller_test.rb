require "test_helper"

class Admin::PasswordsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    @admin = admin_users(:one)
    ActionMailer::Base.deliveries.clear
    clear_enqueued_jobs
    clear_performed_jobs
  end

  teardown do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test "shows reset request page" do
    get admin_new_password_url
    assert_response :success
  end

  test "enqueues reset email for existing admin" do
    assert_enqueued_emails 1 do
      post admin_password_url, params: { email: @admin.email }
    end

    assert_redirected_to admin_login_url
  end

  test "edit works with valid token and update changes password" do
    token = @admin.password_reset_token

    get admin_edit_password_url(token: token)
    assert_response :success

    patch admin_password_edit_url(token: token), params: {
      password: "new-secure-password-123",
      password_confirmation: "new-secure-password-123"
    }

    assert_redirected_to admin_login_url

    post admin_login_url, params: {
      email: @admin.email,
      password: "new-secure-password-123"
    }

    assert_redirected_to admin_root_url
  end

  test "invalid token redirects to reset request page" do
    get admin_edit_password_url(token: "invalid")

    assert_redirected_to admin_new_password_url
  end
end
