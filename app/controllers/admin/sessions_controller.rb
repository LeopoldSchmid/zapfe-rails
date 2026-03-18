class Admin::SessionsController < ApplicationController
  layout "admin_auth"
  before_action :enforce_rate_limits, only: :create

  def new
    return unless admin_signed_in?

    redirect_to admin_root_path
  end

  def create
    user = AdminUser.find_by(email: params[:email]&.downcase&.strip)

    if user&.authenticate(params[:password])
      session[:admin_user_id] = user.id
      redirect_to admin_root_path, notice: "Login erfolgreich."
    else
      flash.now[:alert] = "Ungültige Zugangsdaten."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to admin_login_path, notice: "Abgemeldet."
  end

  private

  def enforce_rate_limits
    return unless rate_limit_exceeded?(scope: "admin:sessions:create", limit: 10, window: 3.minutes)

    rate_limit_exceeded
  end

  def rate_limit_exceeded
    redirect_to admin_login_path, alert: "Zu viele Login-Versuche. Bitte versuche es in ein paar Minuten erneut."
  end
end
