require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_url
    assert_response :success
    assert_match "<title>Mobile Zapfanlage mieten in Freiburg | Zapfe!</title>", response.body
    assert_match "property=\"og:title\" content=\"Mobile Zapfanlage mieten in Freiburg | Zapfe!\"", response.body
    assert_match "rel=\"canonical\" href=\"http://www.example.com/\"", response.body
    assert_match "\"@type\":\"LocalBusiness\"", response.body
    assert_match "/optimized/zapfe-hero-desktop.jpg", response.body
    assert_match "/optimized/zapfe-features-desktop.png", response.body
    assert_no_match "/zapfe_incl_description.png", response.body
    assert_no_match "/zapfe_numbers.png", response.body
  end

  test "should get events" do
    get events_url
    assert_response :success
  end

  test "should get local seo landing pages" do
    get zapfanlage_mieten_freiburg_url
    assert_response :success

    get loesungen_firmenveranstaltungen_url
    assert_response :success

    get loesungen_hochzeiten_url
    assert_response :success
  end

  test "should get drinks" do
    get drinks_url
    assert_response :success
    assert_match "drinks-no-results", response.body
  end

  test "drinks page renders even when query params are present" do
    get drinks_url, params: { q: "Roth" }
    assert_response :success
    assert_match "Rothaus", response.body
    assert_match "value=\"Fritz\"", response.body
  end

  test "drinks page renders even when availability params are present" do
    get drinks_url, params: { available: "1" }
    assert_response :success
  end

  test "should get calculator" do
    get calculator_url
    assert_response :success
    assert_match "<title>Preisrechner für mobile Zapfanlage | Zapfe!</title>", response.body
    assert_match "\"@type\":\"FAQPage\"", response.body
    assert_match "calc-no-results", response.body
  end

  test "should get solutions" do
    get solutions_url
    assert_response :success
    assert_match "<title>Self-Service Lösungen für Ausschank und Verkauf | Zapfe!</title>", response.body
  end

  test "should get contact" do
    get contact_url
    assert_response :success
  end

  test "robots and sitemap are available" do
    get "/robots.txt"
    assert_response :success
    assert_match "Sitemap:", response.body

    get "/sitemap.xml"
    assert_response :success
    assert_match "<urlset", response.body
    assert_match "zapfanlage-mieten-freiburg", response.body
  end
end
