require "test_helper"

class Admin::AuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @user = admin_users(:one)
  end

  test "member can work operationally but cannot access management or owner areas" do
    sign_in_admin(@user, role: "member")

    get admin_root_url
    assert_response :success
    get admin_orders_url
    assert_response :success
    get admin_products_url
    assert_response :forbidden
    get admin_admin_users_url
    assert_response :forbidden
  end

  test "admin can manage catalog but cannot manage accounts or system settings" do
    sign_in_admin(@user, role: "admin")

    get admin_products_url
    assert_response :success
    get admin_admin_users_url
    assert_response :forbidden
    get edit_admin_system_settings_url
    assert_response :forbidden
  end

  test "owner can access every privilege tier" do
    sign_in_admin(@user, role: "owner")

    get admin_orders_url
    assert_response :success
    get admin_products_url
    assert_response :success
    get admin_admin_users_url
    assert_response :success
    get edit_admin_system_settings_url
    assert_response :success
  end

  test "denials are recorded without raw IP or user agent" do
    sign_in_admin(@user, role: "member")

    assert_difference("AdminSecurityEvent.where(event_type: 'authorization_denied').count", 1) do
      get admin_admin_users_url, headers: { "User-Agent" => "Secret Browser/1.0" }
    end

    event = AdminSecurityEvent.order(:id).last
    assert_not_equal "127.0.0.1", event.ip_address_digest
    assert_equal "other", event.user_agent_family
    assert_not_includes event.metadata.to_json, "Secret Browser"
  end
end
