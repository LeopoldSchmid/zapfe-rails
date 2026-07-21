require "prawn"
require "prawn/table"

class Invoices::PdfRenderer
  def initialize(invoice:)
    @invoice = invoice
    @snapshot = invoice.document_snapshot_data
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 45) do |pdf|
      issuer = @snapshot.fetch("issuer")
      recipient = @snapshot.fetch("recipient")
      pdf.fill_color "102A43"
      pdf.text "zapfe.", size: 26, style: :bold
      pdf.fill_color "000000"
      pdf.text issuer.fetch("company_name"), size: 9
      pdf.text issuer.fetch("company_address").to_s, size: 9
      pdf.move_down 32
      pdf.text document_title, size: 22, style: :bold, color: "102A43"
      pdf.move_down 12
      pdf.text recipient.fetch("name"), style: :bold
      pdf.text recipient.fetch("address").to_s
      pdf.move_down 18
      pdf.text "Rechnungsnummer: #{@invoice.invoice_number}"
      pdf.text "Bezug auf Rechnung: #{@snapshot.fetch("correction_of")}" if @snapshot["correction_of"].present?
      pdf.text "Rechnungsdatum: #{I18n.l(Date.iso8601(@snapshot.fetch("issue_date")))}"
      pdf.text "Lieferdatum: #{format_date(@snapshot["delivery_on"])}"
      pdf.text "Zahlbar bis: #{format_date(@snapshot["due_on"])}"
      pdf.move_down 22
      pdf.text "Vielen Dank für Ihren Auftrag. Für die erbrachten Leistungen stellen wir Ihnen folgende Summe in Rechnung:", leading: 4
      pdf.move_down 16
      rows = [ [ "Beschreibung", "Menge", "Einheit", "Einzelpreis", "USt.", "Netto" ] ] + @snapshot.fetch("line_items").map { |item| [ item.fetch("description"), item.fetch("quantity"), item.fetch("unit"), money(item.fetch("net_unit_price")), "#{item.fetch("tax_rate")} %", money(item.fetch("net_total")) ] }
      pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { padding: 7, size: 9 }) do
        row(0).background_color = "EAF0F5"
        row(0).font_style = :bold
        columns(1..5).align = :right
      end
      pdf.move_down 14
      totals = @snapshot.fetch("totals")
      pdf.bounding_box([ pdf.bounds.right - 205, pdf.cursor ], width: 205) do
        pdf.text "Teilsumme netto: #{money(totals.fetch("subtotal_net"))}", align: :right
        pdf.text "Rabatt: -#{money(totals.fetch("global_discount_amount"))}", align: :right if BigDecimal(totals.fetch("global_discount_amount")) > 0
        @snapshot.fetch("tax_breakdown").each do |tax|
          pdf.text "USt. #{tax.fetch("rate")} % auf #{money(tax.fetch("taxable_basis"))}: #{money(tax.fetch("tax_amount"))}", align: :right
        end
        pdf.move_down 5
        pdf.stroke_horizontal_rule
        pdf.move_down 5
        pdf.text "Rechnungssumme: #{money(totals.fetch("gross"))}", align: :right, style: :bold, size: 12
      end
      pdf.move_down 85
      pdf.text "Die vollständige Rechnungssumme ist innerhalb der angegebenen Zahlungsfrist ohne Abzug zu zahlen.", size: 9
      pdf.move_down 24
      pdf.fill_color "52606D"
      pdf.text "#{issuer.fetch("company_name")} · USt.-ID: #{issuer.fetch("vat_id")}", size: 8
      pdf.text "Bank: #{issuer.fetch("bank_name")} · IBAN: #{issuer.fetch("iban")} · BIC: #{issuer.fetch("bic")}", size: 8
    end.render
  end

  def money(value) = format("%.2f €", BigDecimal(value.to_s))
  def format_date(value) = value.present? ? I18n.l(Date.iso8601(value)) : "–"
  def document_title = @snapshot.fetch("invoice_type") == "credit_note" ? "STORNORECHNUNG" : "RECHNUNG"
end
