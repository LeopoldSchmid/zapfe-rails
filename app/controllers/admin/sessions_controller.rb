class Admin::SessionsController < ApplicationController
  PENDING_AUTH_MAX_AGE = 10.minutes

  layout "admin_auth"
  before_action :load_pending_admin, only: %i[mfa verify_mfa setup_mfa enable_mfa]
  before_action :enforce_login_rate_limits, only: :create
  before_action :enforce_mfa_rate_limits, only: %i[verify_mfa enable_mfa]

  def new
    return unless admin_signed_in?

    redirect_to admin_root_path
  end

  def create
    email = params[:email].to_s.downcase.strip
    user = AdminUser.find_by(email: email)

    if user&.active? && user.authenticate(params[:password])
      begin_pending_authentication(user)
      AdminSecurity::Audit.log(event_type: :login_succeeded, target: user, request: request)
      redirect_to user.mfa_enabled? ? admin_login_mfa_path : admin_login_mfa_setup_path
    else
      AdminSecurity::Audit.log(event_type: :login_failed, target: user, request: request, metadata: { reason: AdminSecurity::Audit.opaque_identifier(email) })
      flash.now[:alert] = "Ungültige Zugangsdaten."
      render :new, status: :unprocessable_entity
    end
  end

  def mfa
    redirect_to admin_login_mfa_setup_path unless @pending_admin.mfa_enabled?
  end

  def verify_mfa
    result = @pending_admin.verify_mfa_code(params[:code])
    if result
      AdminSecurity::Audit.log(
        event_type: result == :recovery ? :mfa_recovery_used : :mfa_challenge_succeeded,
        target: @pending_admin,
        request: request,
        metadata: { recovery_code: result == :recovery }
      )
      complete_authentication(@pending_admin)
      redirect_to admin_root_path, notice: result == :recovery ? "Mit Wiederherstellungscode angemeldet. Verbleibend: #{@pending_admin.recovery_codes_remaining}." : "Login erfolgreich."
    else
      AdminSecurity::Audit.log(event_type: :mfa_challenge_failed, target: @pending_admin, request: request)
      flash.now[:alert] = "Ungültiger oder bereits verwendeter Sicherheitscode."
      render :mfa, status: :unprocessable_entity
    end
  end

  def setup_mfa
    return redirect_to admin_login_mfa_path if @pending_admin.mfa_enabled?

    @mfa_secret = session[:pending_mfa_secret] ||= ROTP::Base32.random(20)
    @provisioning_uri = @pending_admin.provisioning_uri(@mfa_secret)
  end

  def enable_mfa
    return redirect_to admin_login_mfa_path if @pending_admin.mfa_enabled?

    secret = session[:pending_mfa_secret]
    timestamp = secret && ROTP::TOTP.new(secret, issuer: "Zapfe Admin").verify(params[:code].to_s.delete(" "), drift_behind: 30, drift_ahead: 30)
    unless timestamp
      AdminSecurity::Audit.log(event_type: :mfa_challenge_failed, target: @pending_admin, request: request)
      flash.now[:alert] = "Der Sicherheitscode ist ungültig."
      return setup_mfa_and_render
    end

    @recovery_codes = AdminSecurity::RecoveryCodes.generate
    @pending_admin.enable_mfa!(secret: secret, recovery_codes: @recovery_codes)
    AdminSecurity::Audit.log(event_type: :mfa_enrolled, target: @pending_admin, request: request)
    complete_authentication(@pending_admin)
    render :recovery_codes
  end

  def destroy
    AdminSecurity::Audit.log(event_type: :logout, actor: current_admin_user, target: current_admin_user, request: request) if current_admin_user
    reset_session
    redirect_to admin_login_path, notice: "Abgemeldet."
  end

  private

  def begin_pending_authentication(user)
    reset_session
    session[:pending_admin_user_id] = user.id
    session[:pending_authenticated_at] = Time.current.to_i
  end

  def complete_authentication(user)
    reset_session
    session[:admin_user_id] = user.id
    session[:admin_session_version] = user.session_version
    session[:admin_authenticated_at] = Time.current.to_i
    session[:admin_last_seen_at] = Time.current.to_i
    user.update_column(:last_signed_in_at, Time.current)
  end

  def load_pending_admin
    authenticated_at = Time.zone.at(session[:pending_authenticated_at].to_i)
    @pending_admin = AdminUser.active.find_by(id: session[:pending_admin_user_id])
    return if @pending_admin && authenticated_at >= PENDING_AUTH_MAX_AGE.ago

    reset_session
    redirect_to admin_login_path, alert: "Die Anmeldung ist abgelaufen. Bitte erneut anmelden."
  end

  def setup_mfa_and_render
    @mfa_secret = session[:pending_mfa_secret] ||= ROTP::Base32.random(20)
    @provisioning_uri = @pending_admin.provisioning_uri(@mfa_secret)
    render :setup_mfa, status: :unprocessable_entity
  end

  def enforce_login_rate_limits
    email = params[:email].to_s.downcase.strip
    exceeded = rate_limit_exceeded?(scope: "admin:sessions:ip", limit: 10, window: 3.minutes) |
      rate_limit_exceeded?(scope: "admin:sessions:account", limit: 10, window: 15.minutes, discriminator: AdminSecurity::Audit.opaque_identifier(email))
    rate_limit_response if exceeded
  end

  def enforce_mfa_rate_limits
    discriminator = session[:pending_admin_user_id].to_s
    exceeded = rate_limit_exceeded?(scope: "admin:mfa:ip", limit: 10, window: 5.minutes) |
      rate_limit_exceeded?(scope: "admin:mfa:account", limit: 10, window: 15.minutes, discriminator: discriminator)
    rate_limit_response if exceeded
  end

  def rate_limit_response
    reset_session
    redirect_to admin_login_path, alert: "Zu viele Anmeldeversuche. Bitte versuche es später erneut."
  end
end
