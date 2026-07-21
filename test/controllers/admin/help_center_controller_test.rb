require "test_helper"

class Admin::HelpCenterControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = admin_users(:one)
    sign_in_admin(admin)
  end

  test "shows contextual help on an admin page" do
    get admin_orders_url

    assert_response :success
    assert_select ".admin-help-button"
    assert_select "dialog.admin-help-dialog"
  end

  test "creates a question for the current admin" do
    assert_difference "HelpRequest.count", 1 do
      post admin_help_requests_url, params: {
        help_request: {
          topic: "orders",
          page_path: "/admin/orders",
          subject: "Unklare Position",
          message: "Wie wird eine Mietposition angelegt?"
        }
      }
    end

    assert_redirected_to admin_root_url
    assert_equal admin_users(:one), HelpRequest.last.admin_user
  end

  test "creates an article with faq entries" do
    assert_difference [ "HelpArticle.count", "HelpFaq.count" ], 1 do
      post admin_help_articles_url, params: {
        help_article: {
          topic: "orders",
          title: "Aufträge bearbeiten",
          body: "Kurze Anleitung.",
          faqs_attributes: { "0" => { question: "Wann ist ein Auftrag fertig?", answer: "Nach Abschluss aller Schritte.", position: 1 } }
        }
      }
    end

    assert_redirected_to admin_help_articles_url
  end
end
