require "test_helper"

class MonitoringControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_token = ENV["MONITORING_TOKEN"]
    ENV["MONITORING_TOKEN"] = "test-monitoring-token"
  end

  teardown do
    ENV["MONITORING_TOKEN"] = @original_token
  end

  test "returns unauthorized without token" do
    get "/monitoring/inquiry_flow"
    assert_response :unauthorized
  end

  test "returns unauthorized with wrong token" do
    get "/monitoring/inquiry_flow", params: { token: "wrong" }
    assert_response :unauthorized
  end

  test "returns ok with valid token" do
    get "/monitoring/inquiry_flow", params: { token: "test-monitoring-token" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "ok", payload["status"]
  end
end
