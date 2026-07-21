module Invoices
  class Cancel
    NotCancellable = Class.new(StandardError)

    def initialize(invoice:, admin_user:, reason:)
      @invoice = invoice
      @admin_user = admin_user
      @reason = reason.to_s.squish
    end

    def call
      Invoice.transaction do
        @invoice.with_lock do
          existing = @invoice.corrections.find_by(invoice_type: "credit_note")
          return existing if existing&.status == "finalized"

          raise NotCancellable, "Nur finalisierte, versendete oder bezahlte Rechnungen können storniert werden." unless @invoice.status.in?(%w[finalized sent paid overdue])
          raise NotCancellable, "Für eine Stornorechnung ist eine Begründung erforderlich." if @reason.blank?

          credit_note = build_credit_note
          credit_note.save!
          copy_line_items(credit_note)
          Invoices::Finalize.new(invoice: credit_note, admin_user: @admin_user).call
          @invoice.update!(status: "cancelled", cancelled_at: Time.current)
          @invoice.activities.create!(admin_user: @admin_user, event_type: "cancelled", message: "Rechnung #{@invoice.invoice_number} durch #{credit_note.invoice_number} storniert: #{@reason}")
          credit_note.activities.create!(admin_user: @admin_user, event_type: "credit_note", message: "Stornorechnung zu #{@invoice.invoice_number}: #{@reason}")
          credit_note
        end
      end
    end

    private

    def build_credit_note
      @invoice.order.invoices.build(
        correction_of: @invoice,
        invoice_type: "credit_note",
        recipient_name: @invoice.recipient_name,
        recipient_email: @invoice.recipient_email,
        recipient_address: @invoice.recipient_address,
        delivery_on: @invoice.delivery_on,
        due_on: Date.current,
        global_discount_type: @invoice.global_discount_type,
        global_discount_value: @invoice.global_discount_value,
        global_discount_reason: @invoice.global_discount_reason,
        internal_note: @reason
      )
    end

    def copy_line_items(credit_note)
      @invoice.line_items.order(:position, :created_at).each do |line_item|
        credit_note.line_items.create!(line_item.attributes.slice(
          "description", "quantity", "unit", "net_unit_price", "discount_type",
          "discount_value", "discount_reason", "tax_rate", "position"
        ))
      end
    end
  end
end
