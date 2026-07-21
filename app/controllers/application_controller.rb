class ApplicationController < ActionController::Base
  ADMIN_IDLE_TIMEOUT = 30.minutes
  ADMIN_MAX_SESSION_AGE = 12.hours
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

    @current_admin_user ||= begin
      user = AdminUser.active.find_by(id: session[:admin_user_id])
      if valid_admin_session?(user)
        session[:admin_last_seen_at] = Time.current.to_i
        user
      else
        reset_session
        nil
      end
    end
  end

  def admin_signed_in?
    current_admin_user.present?
  end

  def require_admin!
    return if admin_signed_in?

    redirect_to admin_login_path, alert: "Bitte zuerst im Admin anmelden."
  end

  def rate_limit_exceeded?(scope:, limit:, window:, discriminator: request.remote_ip)
    cache_key = [ "rate-limit", scope, discriminator ].join(":")
    count = RATE_LIMIT_STORE.increment(cache_key, 1, expires_in: window)
    count.present? && count > limit
  end

  def valid_admin_session?(user)
    return false unless user
    return false unless session[:admin_session_version].to_i == user.session_version

    authenticated_at = Time.zone.at(session[:admin_authenticated_at].to_i)
    last_seen_at = Time.zone.at(session[:admin_last_seen_at].to_i)
    authenticated_at >= ADMIN_MAX_SESSION_AGE.ago && last_seen_at >= ADMIN_IDLE_TIMEOUT.ago
  end
end
