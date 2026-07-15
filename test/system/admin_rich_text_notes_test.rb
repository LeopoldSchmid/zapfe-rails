require "application_system_test_case"

class AdminRichTextNotesTest < ApplicationSystemTestCase
  test "edits freeform notes with the reusable rich text editor" do
    admin = admin_users(:one)
    order = orders(:from_inquiry)

    visit admin_login_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Einloggen"
    assert_current_path admin_root_path

    visit notes_admin_order_path(order)
    assert_selector "lexxy-editor"
    assert_no_selector "trix-editor"
  end
end
