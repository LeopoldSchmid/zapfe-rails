class InquiriesController < ApplicationController
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

  def inquiry_params
    params.require(:inquiry).permit(
      :source,
      :first_name,
      :last_name,
      :email,
      :phone,
      :event_type,
      :event_date,
      :guests,
      :message,
      :selected_options,
      :total_price,
      :pricing_snapshot,
      :privacy_accepted
    )
  end
end
