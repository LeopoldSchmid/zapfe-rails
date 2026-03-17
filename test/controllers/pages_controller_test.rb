require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_url
    assert_response :success
    assert_match "<title>Mobile Zapfanlagen zur Selbstbedienung | Zapfe!</title>", response.body
    assert_match "property=\"og:title\" content=\"Mobile Zapfanlagen zur Selbstbedienung | Zapfe!\"", response.body
    assert_match "rel=\"canonical\" href=\"http://www.example.com/\"", response.body
    assert_match "\"@type\":\"LocalBusiness\"", response.body
    assert_match "Temporär", response.body
    assert_match "Dauerhaft", response.body
  end

  test "should get events" do
    get events_url
    assert_response :success
  end

  test "should get drinks" do
    get drinks_url
    assert_response :success
    assert_match "Getränkeauswahl", response.body
    assert_match "Zum Preisrechner", response.body
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
    assert_match "<title>Preisrechner für Selbstbedienungs-Zapfanlagen | Zapfe!</title>", response.body
    assert_match "\"@type\":\"FAQPage\"", response.body
    assert_match "Event-Rechner", response.body
    assert_match "calc-own-drinks-note", response.body
  end

  test "should get solutions" do
    get solutions_url
    assert_response :success
    assert_match "<title>Selbstbedienungs-Zapfanlagen für den dauerhaften Betrieb | Zapfe!</title>", response.body
  end

  test "should get cta preview" do
    get "/cta-preview"
    assert_response :success
    assert_match "CTA Studien", response.body
    assert_match "Compact Pill", response.body
    assert_match "Split Button", response.body
    assert_match "Mini Card CTA", response.body
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
    assert_match "solutions", response.body
    assert_no_match "zapfanlage-mieten-freiburg", response.body
  end
end
