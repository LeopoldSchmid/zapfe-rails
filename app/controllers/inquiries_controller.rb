class InquiriesController < ApplicationController
  MINIMUM_SUBMISSION_TIME = 3.seconds
  MAXIMUM_SUBMISSION_AGE = 2.days

  before_action :reject_spam_submission, only: :create
  before_action :enforce_rate_limits, only: :create

  def create
    @inquiry = Inquiry.new(inquiry_params)

    if @inquiry.save
      InquiryMailer.customer_confirmation(@inquiry).deliver_later
      InquiryMailer.admin_notification(@inquiry).deliver_later
      redirect_back fallback_location: root_path, notice: "Vielen Dank! Deine Anfrage wurde gesendet."
    else
      redirect_back fallback_location: root_path, alert: @inquiry.errors.full_messages.to_sentence
    end
  end

  private

  def reject_spam_submission
    reason = spam_submission_reason
    return unless reason

    Rails.logger.info(
      "Blocked spam inquiry reason=#{reason} ip=#{request.remote_ip} " \
      "source=#{raw_inquiry_params[:source].to_s.first(50)} " \
      "email=#{raw_inquiry_params[:email].to_s.first(200)} " \
      "user_agent=#{request.user_agent.to_s.first(200)}"
    )

    redirect_back fallback_location: root_path, notice: "Vielen Dank! Deine Anfrage wurde gesendet."
  end

  def enforce_rate_limits
    return unless rate_limit_exceeded?(scope: "inquiries:create:burst", limit: 5, window: 5.minutes) ||
                  rate_limit_exceeded?(scope: "inquiries:create:hourly", limit: 20, window: 1.hour)

    rate_limit_exceeded
  end

  def rate_limit_exceeded
    redirect_back fallback_location: root_path, alert: "Zu viele Anfragen in kurzer Zeit. Bitte versuche es in ein paar Minuten erneut."
  end

  def spam_submission_reason
    @spam_submission_reason ||= begin
      return :honeypot if raw_inquiry_params[:website].present?
      return :missing_timestamp if raw_inquiry_params[:submitted_at_token].blank?

      timestamp = verified_submission_timestamp
      return :invalid_timestamp if timestamp.blank?

      age = Time.current - Time.at(timestamp)
      return :submitted_too_fast if age < MINIMUM_SUBMISSION_TIME
      return :stale_form if age > MAXIMUM_SUBMISSION_AGE

      nil
    end
  end

  def verified_submission_timestamp
    Rails.application.message_verifier(:inquiry_form).verified(
      raw_inquiry_params[:submitted_at_token],
      purpose: :inquiry_form
    )
  end

  def raw_inquiry_params
    params.fetch(:inquiry, ActionController::Parameters.new).permit!.to_h.symbolize_keys
  end

  def inquiry_params
    params.require(:inquiry).permit(
      :source,
      :first_name,
      :last_name,
      :email,
      :phone,
      :event_type,
      :event_date,
      :rental_mode,
      :rental_days,
      :starts_on,
      :ends_on,
      :start_time,
      :end_time,
      :delivery_street,
      :delivery_postcode,
      :delivery_city,
      :bring_own_drinks,
      :glasses_requested,
      :guests,
      :message,
      :selected_options,
      :total_price,
      :pricing_snapshot,
      :privacy_accepted
    )
  end
end
