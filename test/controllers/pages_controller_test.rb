require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_url
    assert_response :success
  end

  test "should get events" do
    get events_url
    assert_response :success
  end

  test "should get drinks" do
    get drinks_url
    assert_response :success
  end

  test "drinks supports query filtering" do
    get drinks_url, params: { q: "Roth" }
    assert_response :success
    assert_match "Rothaus", response.body
    assert_no_match "Fritz Cola", response.body
  end

  test "drinks supports availability flag" do
    get drinks_url, params: { available: "1" }
    assert_response :success
  end

  test "should get calculator" do
    get calculator_url
    assert_response :success
  end

  test "should get contact" do
    get contact_url
    assert_response :success
  end
end
