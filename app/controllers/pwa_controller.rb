class PwaController < ActionController::Base
  skip_forgery_protection

  def manifest
    expires_in 1.hour, public: true
    render :manifest, content_type: "application/manifest+json", layout: false
  end

  def service_worker
    expires_in 0, public: true, must_revalidate: true
    render :service_worker, content_type: "application/javascript", layout: false
  end
end
