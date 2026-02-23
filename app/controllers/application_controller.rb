class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_admin_user, :admin_signed_in?

  private

  def current_admin_user
    return nil unless session[:admin_user_id]

    @current_admin_user ||= AdminUser.find_by(id: session[:admin_user_id])
  end

  def admin_signed_in?
    current_admin_user.present?
  end

  def require_admin!
    return if admin_signed_in?

    redirect_to admin_login_path, alert: "Bitte zuerst im Admin anmelden."
  end
end
