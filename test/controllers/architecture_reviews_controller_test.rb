require "test_helper"

class ArchitectureReviewsControllerTest < ActionDispatch::IntegrationTest
  test "renders the temporary review quest with every finding" do
    get architecture_review_url

    assert_response :success
    assert_select "meta[name='robots'][content='noindex,nofollow,noarchive']"
    assert_select "h1", text: /produktionsreif/i
    assert_select "[data-review-quest-target='card']", 54
    assert_match "60 Findings", response.body
    assert_match "SEC-001", response.body
    assert_match "OPS-002", response.body
    assert_match "PRIV-003", response.body
    assert_match "LEG-006", response.body
    assert_match "A11Y-005", response.body
  end
end
