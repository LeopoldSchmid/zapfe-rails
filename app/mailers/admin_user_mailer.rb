class AdminUserMailer < ApplicationMailer
  def password_reset(admin_user)
    @admin_user = admin_user
    @reset_url = admin_edit_password_url(token: @admin_user.password_reset_token)

    mail(to: @admin_user.email, subject: "Zapfe Admin Passwort zurücksetzen")
  end
end
