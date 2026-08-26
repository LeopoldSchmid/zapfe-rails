class Admin::SessionsController < ApplicationController
  layout "admin_auth"
  before_action :enforce_login_rate_limits, only: :create

  def new
    return unless admin_signed_in?

    redirect_to admin_root_path
  end

  def create
    email = params[:email].to_s.downcase.strip
    user = AdminUser.find_by(email: email)

    if user&.active? && user.authenticate(params[:password])
      AdminSecurity::Audit.log(event_type: :login_succeeded, target: user, request: request)
      complete_authentication(user)
      redirect_to admin_root_path
    else
      AdminSecurity::Audit.log(event_type: :login_failed, target: user, request: request, metadata: { reason: AdminSecurity::Audit.opaque_identifier(email) })
      flash.now[:alert] = "Ungültige Zugangsdaten."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    AdminSecurity::Audit.log(event_type: :logout, actor: current_admin_user, target: current_admin_user, request: request) if current_admin_user
    reset_session
    redirect_to admin_login_path, notice: "Abgemeldet."
  end

  private

  def complete_authentication(user)
    reset_session
    session[:admin_user_id] = user.id
    session[:admin_session_version] = user.session_version
    session[:admin_authenticated_at] = Time.current.to_i
    session[:admin_last_seen_at] = Time.current.to_i
    user.update_column(:last_signed_in_at, Time.current)
  end

  def enforce_login_rate_limits
    email = params[:email].to_s.downcase.strip
    exceeded = rate_limit_exceeded?(scope: "admin:sessions:ip", limit: 10, window: 3.minutes) |
      rate_limit_exceeded?(scope: "admin:sessions:account", limit: 10, window: 15.minutes, discriminator: AdminSecurity::Audit.opaque_identifier(email))
    rate_limit_response if exceeded
  end

  def rate_limit_response
    reset_session
    redirect_to admin_login_path, alert: "Zu viele Anmeldeversuche. Bitte versuche es später erneut."
  end
end
