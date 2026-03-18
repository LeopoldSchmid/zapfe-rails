class InquiriesController < ApplicationController
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

  def enforce_rate_limits
    return unless rate_limit_exceeded?(scope: "inquiries:create:burst", limit: 5, window: 5.minutes) ||
                  rate_limit_exceeded?(scope: "inquiries:create:hourly", limit: 20, window: 1.hour)

    rate_limit_exceeded
  end

  def rate_limit_exceeded
    redirect_back fallback_location: root_path, alert: "Zu viele Anfragen in kurzer Zeit. Bitte versuche es in ein paar Minuten erneut."
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
