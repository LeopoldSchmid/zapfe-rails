require "test_helper"

class Admin::ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = admin_users(:one)
    post admin_login_url, params: { email: admin.email, password: "password123" }
  end

  test "creates a concrete active resource" do
    assert_difference("Resource.count", 1) do
      post admin_resources_url, params: { resource: { name: "Ape #1", resource_type: "Ape", active: "1", configuration_notes: "2 Zapfhähne" } }
    end

    assert_redirected_to admin_resources_url
  end
end
