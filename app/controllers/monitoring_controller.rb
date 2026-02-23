class MonitoringController < ApplicationController
  def inquiry_flow
    return head :unauthorized unless monitoring_token_valid?

    inquiry = Inquiry.new(
      source: "contact",
      first_name: "Monitoring",
      last_name: "Check",
      email: "monitoring@example.invalid",
      phone: "+4900000000",
      privacy_accepted: true
    )

    unless inquiry.valid?
      return render json: { status: "error", error: inquiry.errors.full_messages.to_sentence }, status: :internal_server_error
    end

    # Build both emails to validate rendering + mailer configuration path without creating DB records.
    InquiryMailer.customer_confirmation(inquiry).message
    InquiryMailer.admin_notification(inquiry).message

    render json: { status: "ok", checked_at: Time.current.iso8601 }, status: :ok
  rescue => error
    render json: { status: "error", error: error.class.name, message: error.message }, status: :internal_server_error
  end

  private

  def monitoring_token_valid?
    expected = ENV["MONITORING_TOKEN"].to_s
    provided = params[:token].to_s
    return false if expected.blank? || provided.blank?

    ActiveSupport::SecurityUtils.secure_compare(provided, expected)
  end
end
