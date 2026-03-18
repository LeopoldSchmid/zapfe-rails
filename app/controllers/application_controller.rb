class ApplicationController < ActionController::Base
  RATE_LIMIT_STORE = if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
    ActiveSupport::Cache::MemoryStore.new
  else
    Rails.cache
  end

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

  def rate_limit_exceeded?(scope:, limit:, window:, discriminator: request.remote_ip)
    cache_key = ["rate-limit", scope, discriminator].join(":")
    count = RATE_LIMIT_STORE.increment(cache_key, 1, expires_in: window)
    count.present? && count > limit
  end
end
