module Orders
  class CreateFromInquiry
    def initialize(inquiry:, responsible_admin_user:)
      @inquiry = inquiry
      @responsible_admin_user = responsible_admin_user
    end

    def call
      @inquiry.with_lock do
        return @inquiry.order if @inquiry.order

        responsible_admin = @inquiry.assigned_admin_user || @responsible_admin_user
        @inquiry.update!(assigned_admin_user: responsible_admin) unless @inquiry.assigned_admin_user

        Order.create!(
          inquiry: @inquiry,
          responsible_admin_user: responsible_admin,
          customer_name: @inquiry.customer_name,
          customer_email: @inquiry.email,
          customer_phone: @inquiry.phone,
          event_type: @inquiry.event_type,
          event_date: @inquiry.event_date || @inquiry.starts_on,
          starts_on: @inquiry.starts_on,
          ends_on: @inquiry.ends_on,
          start_time: @inquiry.start_time,
          end_time: @inquiry.end_time,
          event_location: @inquiry.delivery_address.presence || "Noch zu klären",
          guests: @inquiry.guests,
          customer_message: @inquiry.message,
          inquiry_pricing_snapshot: @inquiry.pricing_snapshot,
          next_step: @inquiry.next_step,
          next_step_due_on: @inquiry.next_step_due_on
        ).tap do |order|
          @inquiry.update!(status: "closed", closure_reason: "In Auftrag umgewandelt")
          Activity.create!(admin_user: responsible_admin, subject: @inquiry, event_type: "converted_to_order", message: "In Auftrag umgewandelt", metadata: { order_id: order.id })
          Activity.create!(admin_user: responsible_admin, subject: order, event_type: "created_from_inquiry", message: "Aus Anfrage erstellt", metadata: { inquiry_id: @inquiry.id })
        end
      end
    end
  end
end
