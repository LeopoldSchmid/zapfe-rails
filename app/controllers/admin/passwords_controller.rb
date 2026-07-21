class Admin::PasswordsController < ApplicationController
  layout "admin_auth"
  before_action :set_admin_by_token, only: %i[edit update]
  before_action :enforce_rate_limits, only: :create

  def new
  end

  def create
    normalized_email = params[:email].to_s.downcase.strip
    if (admin_user = AdminUser.find_by(email: normalized_email))
      AdminUserMailer.password_reset(admin_user).deliver_later
    end
    AdminSecurity::Audit.log(event_type: :password_reset_requested, target: admin_user, request: request, metadata: { reason: AdminSecurity::Audit.opaque_identifier(normalized_email) })

    redirect_to admin_login_path, notice: "Wenn ein Admin mit dieser E-Mail existiert, wurde ein Reset-Link versendet."
  end

  def edit
  end

  def update
    if @admin_user.update(password_params)
      AdminSecurity::Audit.log(event_type: :password_changed, target: @admin_user, request: request)
      redirect_to admin_login_path, notice: "Passwort aktualisiert. Du kannst dich jetzt anmelden."
    else
      flash.now[:alert] = @admin_user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_admin_by_token
    @admin_user = AdminUser.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to admin_new_password_path, alert: "Der Reset-Link ist ungültig oder abgelaufen."
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def enforce_rate_limits
    normalized_email = params[:email].to_s.downcase.strip
    exceeded = rate_limit_exceeded?(scope: "admin:password-reset:ip", limit: 5, window: 15.minutes) |
      rate_limit_exceeded?(scope: "admin:password-reset:account", limit: 3, window: 1.hour, discriminator: AdminSecurity::Audit.opaque_identifier(normalized_email))
    return unless exceeded

    redirect_to admin_login_path, alert: "Zu viele Reset-Anfragen. Bitte versuche es später erneut."
  end
end
