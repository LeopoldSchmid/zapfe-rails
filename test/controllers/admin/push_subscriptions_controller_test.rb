require "test_helper"

class Admin::PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = admin_users(:one)
    sign_in_admin(admin)
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

  test "queues a test notification for an existing subscription" do
    subscription = PushSubscription.create!(admin_user: admin_users(:one), endpoint: "https://push.example.test/subscription/one", p256dh: "public-key", auth: "auth-key")

    assert_enqueued_with(job: PushNotificationJob) do
      post test_admin_push_subscription_url, params: { push_subscription: { endpoint: subscription.endpoint } }, as: :json
    end

    assert_response :accepted
  end
end
