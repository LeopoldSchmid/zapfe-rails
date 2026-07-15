class Invoices::Finalize
  class NotFinalizable < StandardError; end

  def initialize(invoice:, admin_user:)
    @invoice = invoice
    @admin_user = admin_user
  end

  def call
    SystemSetting.current.with_lock do
      @invoice.with_lock do
        raise NotFinalizable, "Nur Rechnungsentwürfe können finalisiert werden." unless @invoice.editable?
        raise NotFinalizable, "Eine Rechnung benötigt mindestens eine Position." if @invoice.line_items.empty?
        raise NotFinalizable, "Für die Finalisierung sind Rechnungsempfänger und Rechnungsadresse erforderlich." if @invoice.recipient_name.blank? || @invoice.recipient_address.blank?

        @invoice.update!(invoice_number: next_invoice_number, status: "finalized", issue_date: Date.current, finalized_at: Time.current, document_snapshot: snapshot.to_json)
        Invoices::PdfRenderer.new(invoice: @invoice).attach!
        @invoice.activities.create!(admin_user: @admin_user, event_type: "finalized", message: "Rechnung #{@invoice.invoice_number} finalisiert")
        @invoice
      end
    end
  end

  private

  def next_invoice_number
    year = Date.current.year
    sequence = Invoice.where("invoice_number LIKE ?", "R-#{year}-%").count + 1
    format("R-%<year>d-%<sequence>06d", year: year, sequence: sequence)
  end

  def snapshot
    settings = SystemSetting.current
    {
      issuer: {
        company_name: settings.company_name, company_address: settings.company_address, vat_id: settings.vat_id,
        bank_name: settings.bank_name, iban: settings.iban, bic: settings.bic
      },
      recipient: { name: @invoice.recipient_name, email: @invoice.recipient_email, address: @invoice.recipient_address },
      issue_date: Date.current.iso8601, delivery_on: @invoice.delivery_on&.iso8601, due_on: @invoice.due_on&.iso8601,
      totals: { subtotal_net: @invoice.subtotal_net.to_s("F"), global_discount_amount: @invoice.global_discount_amount.to_s("F"), global_discount_reason: @invoice.global_discount_reason, net: @invoice.net_total.to_s("F"), tax: @invoice.tax_total.to_s("F"), gross: @invoice.gross_total.to_s("F") },
      line_items: @invoice.line_items.order(:position, :created_at).map { |line_item| { description: line_item.description, quantity: line_item.quantity.to_s("F"), unit: line_item.unit, net_unit_price: line_item.net_unit_price.to_s("F"), tax_rate: line_item.tax_rate.to_s("F"), net_total: line_item.net_total.to_s("F") } }
    }
  end
end
