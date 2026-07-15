require "test_helper"

class Admin::PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = admin_users(:one)
    post admin_login_url, params: { email: admin.email, password: "password123" }
  end

  test "stores one subscription per browser endpoint" do
    assert_difference "PushSubscription.count", 1 do
      post admin_push_subscription_url, params: {
        push_subscription: {
          endpoint: "https://push.example.test/subscription/one",
          p256dh: "public-key",
          auth: "auth-key"
        }
      }, as: :json
    end

    assert_response :no_content
    assert_equal admin_users(:one), PushSubscription.last.admin_user
  end

  test "updates an existing subscription endpoint" do
    PushSubscription.create!(admin_user: admin_users(:one), endpoint: "https://push.example.test/subscription/one", p256dh: "old", auth: "old")

    assert_no_difference "PushSubscription.count" do
      post admin_push_subscription_url, params: {
        push_subscription: {
          endpoint: "https://push.example.test/subscription/one",
          p256dh: "new-public-key",
          auth: "new-auth-key"
        }
      }, as: :json
    end

    assert_response :no_content
    assert_equal "new-public-key", PushSubscription.last.p256dh
  end
end
