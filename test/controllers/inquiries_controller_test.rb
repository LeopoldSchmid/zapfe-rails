require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  test "should create inquiry" do
    assert_difference("Inquiry.count", 1) do
      post inquiries_url, params: {
        inquiry: {
          source: "contact",
          first_name: "Max",
          last_name: "Mustermann",
          email: "max@example.com",
          phone: "+491234",
          privacy_accepted: "1"
        }
      }
    end

    assert_redirected_to root_url
  end
end
