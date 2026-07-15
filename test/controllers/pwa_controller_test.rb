require "test_helper"

class PwaControllerTest < ActionDispatch::IntegrationTest
  test "serves an admin scoped web manifest" do
    get "/admin/manifest.webmanifest"

    assert_response :success
    assert_equal "application/manifest+json; charset=utf-8", response.content_type
    manifest = JSON.parse(response.body)
    assert_equal "/admin", manifest.fetch("start_url")
    assert_equal "/admin/", manifest.fetch("scope")
    assert_equal "/pwa-icon-512.png", manifest.fetch("icons").last.fetch("src")
  end

  test "serves the service worker without an admin session" do
    get "/service-worker.js"

    assert_response :success
    assert_includes response.body, "addEventListener(\"push\""
  end
end
