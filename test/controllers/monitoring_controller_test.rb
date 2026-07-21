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

  test "rejects query-string tokens even when their value is valid" do
    get "/monitoring/inquiry_flow", params: { token: "test-monitoring-token" }
    assert_response :unauthorized
  end

  test "returns ok with valid bearer token" do
    get "/monitoring/inquiry_flow", headers: bearer_headers

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "ok", payload["status"]
  end

  test "does not expose internal error details" do
    original_method = InquiryMailer.method(:customer_confirmation)

    InquiryMailer.singleton_class.send(:define_method, :customer_confirmation) do |*|
      raise "smtp misconfigured"
    end

    begin
      get "/monitoring/inquiry_flow", headers: bearer_headers
    ensure
      InquiryMailer.singleton_class.send(:define_method, :customer_confirmation) do |*args, &block|
        original_method.call(*args, &block)
      end
    end

    assert_response :internal_server_error
    payload = JSON.parse(response.body)
    assert_equal({ "status" => "error" }, payload)
  end

  test "deep health verifies writable dependencies and cleans probes" do
    assert_no_difference("OperationalProbe.count") do
      post "/monitoring/deep", headers: bearer_headers
    end

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "ok", payload.fetch("status")
    assert_equal %w[cache database_write mail_render queue_database storage], payload.fetch("checks").keys.sort
    assert payload.fetch("checks").values.all? { |check| check.fetch("status") == "ok" }
  end

  private

  def bearer_headers
    { "Authorization" => "Bearer test-monitoring-token" }
  end
end
