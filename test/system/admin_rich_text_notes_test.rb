require "application_system_test_case"

class AdminRichTextNotesTest < ApplicationSystemTestCase
  test "edits freeform notes with the reusable rich text editor" do
    admin = admin_users(:one)
    order = orders(:from_inquiry)

    sign_in_admin_through_ui(admin)
    assert_current_path admin_root_path

    visit notes_admin_order_path(order)
    assert_selector "lexxy-editor.lexxy-content.admin-rich-text"
    assert_no_selector "trix-editor"
  end
end
