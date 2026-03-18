require "test_helper"

class AdminUserMailerTest < ActionMailer::TestCase
  test "password reset" do
    admin = admin_users(:one)
    email = AdminUserMailer.password_reset(admin)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ admin.email ], email.to
    assert_equal "Zapfe Admin Passwort zurücksetzen", email.subject
    assert_includes email.body.encoded, "http://example.com/admin/password/edit?token="
  end
end
