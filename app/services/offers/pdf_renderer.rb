require "prawn"
require "prawn/table"

class Offers::PdfRenderer
  def initialize(offer:)
    @offer = offer
    @snapshot = offer.document_snapshot_data
  end

  def attach!
    @offer.document.attach(
      io: StringIO.new(render),
      filename: "#{@offer.offer_number}.pdf",
      content_type: "application/pdf"
    )
  end

  private

  def render
    Prawn::Document.new(page_size: "A4", margin: 45) do |pdf|
      pdf.fill_color "102A43"
      pdf.text "Zapfe", size: 26, style: :bold
      pdf.fill_color "000000"
      pdf.text "Ape2tap UG · Habsburgerstraße 38 · 79104 Freiburg", size: 9
      pdf.move_down 36

      pdf.text "ANGEBOT", size: 22, style: :bold, color: "102A43"
      pdf.move_down 12
      pdf.text @snapshot.dig("recipient", "name").to_s, style: :bold
      pdf.text @snapshot.dig("recipient", "address").to_s
      pdf.move_down 18
      pdf.text "Angebotsnummer: #{@offer.offer_number}"
      pdf.text "Angebotsdatum: #{I18n.l(@offer.finalized_at.to_date)}"
      pdf.text "Gültig bis: #{I18n.l(Date.iso8601(@snapshot.fetch("valid_until")))}"
      pdf.move_down 24
      pdf.text "Vielen Dank für Ihr Interesse an Zapfe. Für die besprochenen Leistungen bieten wir Ihnen an:", leading: 4
      pdf.move_down 16

      rows = [ [ "Beschreibung", "Menge", "Einheit", "Netto", "Gesamt" ] ] + @snapshot.fetch("line_items").map do |line_item|
        [
          line_item.fetch("description"),
          line_item.fetch("quantity"),
          line_item.fetch("unit"),
          money(line_item.fetch("net_unit_price")),
          money(line_item.fetch("net_total"))
        ]
      end
      pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { padding: 7, size: 9 }) do
        row(0).background_color = "EAF0F5"
        row(0).font_style = :bold
        columns(1..4).align = :right
      end
      pdf.move_down 14
      totals = @snapshot.fetch("totals")
      pdf.float do
        pdf.bounding_box([ pdf.bounds.right - 190, pdf.cursor ], width: 190) do
          pdf.text "Zwischensumme netto: #{money(totals.fetch("subtotal_net"))}", align: :right
          if BigDecimal(totals.fetch("global_discount_amount")) > 0
            pdf.text "Gesamtrabatt#{totals.fetch("global_discount_reason").present? ? " (#{totals.fetch("global_discount_reason")})" : ""}: -#{money(totals.fetch("global_discount_amount"))}", align: :right
          end
          pdf.text "Mehrwertsteuer#{tax_rate_label}: #{money(totals.fetch("tax"))}", align: :right
          pdf.move_down 5
          pdf.stroke_horizontal_rule
          pdf.move_down 5
          pdf.text "Gesamtbetrag: #{money(totals.fetch("gross"))}", align: :right, style: :bold, size: 12
        end
      end
      pdf.move_down 85
      pdf.text "Dieses Angebot ist bis zum #{I18n.l(Date.iso8601(@snapshot.fetch("valid_until")))} gültig. Bitte bestätigen Sie die Annahme schriftlich per E-Mail.", size: 9, leading: 3
      pdf.move_down 24
      pdf.fill_color "52606D"
      pdf.text "Ape2tap UG · USt.-ID: DE369035041 · Geschäftsführer: Leopold Schmid", size: 8
      pdf.text "www.zapfe.jetzt · +49 1XX XXXXXX · E-Mail@zapfe.jetzt", size: 8
    end.render
  end

  def money(value)
    format("%.2f €", BigDecimal(value.to_s))
  end

  def tax_rate_label
    rates = @snapshot.fetch("line_items").map { |line_item| line_item.fetch("tax_rate") }.uniq
    rates.one? ? " (#{rates.first} %)" : ""
  end
end
