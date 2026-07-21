class Invoices::Finalize
  class NotFinalizable < StandardError; end

  def initialize(invoice:, admin_user:, pdf_renderer: Invoices::PdfRenderer, xrechnung_renderer: Invoices::XrechnungRenderer, xrechnung_validator: Invoices::XrechnungValidator)
    @invoice = invoice
    @admin_user = admin_user
    @pdf_renderer = pdf_renderer
    @xrechnung_renderer = xrechnung_renderer
    @xrechnung_validator = xrechnung_validator
  end

  def call
    uploaded_blobs = []
    Invoice.transaction do
      @invoice.with_lock do
        return @invoice if @invoice.status == "finalized" && @invoice.document.attached? && @invoice.e_invoice.attached?

        raise NotFinalizable, "Nur Rechnungsentwürfe können finalisiert werden." unless @invoice.editable?
        raise NotFinalizable, "Eine Rechnung benötigt mindestens eine Position." if @invoice.line_items.empty?
        if @invoice.recipient_name.blank? || @invoice.recipient_address.blank? || @invoice.recipient_email.blank?
          raise NotFinalizable, "Für die Finalisierung sind Rechnungsempfänger, E-Mail und Rechnungsadresse erforderlich."
        end

        number = next_invoice_number
        @invoice.assign_attributes(invoice_number: number, status: "finalized", issue_date: Date.current, finalized_at: Time.current)
        @invoice.document_snapshot = snapshot.to_json
        pdf = @pdf_renderer.new(invoice: @invoice).render
        xml = @xrechnung_renderer.new(invoice: @invoice).render
        @xrechnung_validator.new(xml).validate!
        @invoice.document_sha256 = Digest::SHA256.hexdigest(pdf)
        @invoice.e_invoice_sha256 = Digest::SHA256.hexdigest(xml)
        uploaded_blobs << ActiveStorage::Blob.create_and_upload!(io: StringIO.new(pdf), filename: "#{number}.pdf", content_type: "application/pdf")
        uploaded_blobs << ActiveStorage::Blob.create_and_upload!(io: StringIO.new(xml), filename: "#{number}.xml", content_type: "application/xml")
        @invoice.save!
        @invoice.document.attach(uploaded_blobs.first)
        @invoice.e_invoice.attach(uploaded_blobs.second)
        @invoice.activities.create!(admin_user: @admin_user, event_type: "finalized", message: "Rechnung #{@invoice.invoice_number} finalisiert")
        @invoice
      end
    end
  rescue StandardError
    uploaded_blobs.each { |blob| blob.service.delete(blob.key) }
    raise
  end

  private

  def next_invoice_number
    year = Date.current.year
    sequence = InvoiceSequence.take_next!(year: year)
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
      invoice_type: @invoice.invoice_type,
      correction_of: @invoice.correction_of&.invoice_number,
      totals: { subtotal_net: @invoice.subtotal_net.to_s("F"), global_discount_amount: @invoice.global_discount_amount.to_s("F"), global_discount_reason: @invoice.global_discount_reason, net: @invoice.net_total.to_s("F"), tax: @invoice.tax_total.to_s("F"), gross: @invoice.gross_total.to_s("F") },
      tax_breakdown: @invoice.tax_breakdown.map { |entry| entry.transform_values { |value| value.respond_to?(:to_s) ? value.to_s("F") : value } },
      line_items: @invoice.line_items.order(:position, :created_at).map { |line_item| { id: line_item.id, description: line_item.description, quantity: line_item.quantity.to_s("F"), unit: line_item.unit, net_unit_price: line_item.net_unit_price.to_s("F"), tax_rate: line_item.tax_rate.to_s("F"), net_total: line_item.net_total.to_s("F"), tax_amount: line_item.tax_amount.round(2).to_s("F") } }
    }
  end
end
