module Invoices
  class XrechnungRenderer
    CUSTOMIZATION_ID = "urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0"
    PROFILE_ID = "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0"
    COMMON_NS = {
      "xmlns:cac" => "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2",
      "xmlns:cbc" => "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    }.freeze

    def initialize(invoice:)
      @invoice = invoice
      @snapshot = invoice.document_snapshot_data
    end

    def render
      Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.public_send(root_name, COMMON_NS.merge("xmlns" => root_namespace)) do
          basic(xml, "CustomizationID", CUSTOMIZATION_ID)
          basic(xml, "ProfileID", PROFILE_ID)
          basic(xml, "ID", @invoice.invoice_number)
          basic(xml, "IssueDate", @snapshot.fetch("issue_date"))
          basic(xml, "DueDate", @snapshot.fetch("due_on")) if @snapshot["due_on"].present? && !credit_note?
          basic(xml, type_code_element, credit_note? ? "381" : "380")
          basic(xml, "DocumentCurrencyCode", "EUR")
          basic(xml, "BuyerReference", "NOTPROVIDED")
          supplier_party(xml)
          customer_party(xml)
          delivery(xml)
          payment_means(xml)
          allowance_charges(xml)
          tax_total(xml)
          monetary_total(xml)
          document_lines(xml)
        end
      end.to_xml
    end

    private

    def basic(xml, name, content, attributes = {})
      xml["cbc"].public_send(name, content, attributes)
    end

    def aggregate(xml, name, &block)
      xml["cac"].public_send(name, &block)
    end

    def supplier_party(xml)
      issuer = @snapshot.fetch("issuer")
      aggregate(xml, "AccountingSupplierParty") do
        aggregate(xml, "Party") do
          basic(xml, "EndpointID", ENV.fetch("INVOICE_SENDER_EMAIL", "info@zapfe.jetzt"), "schemeID" => "EM")
          aggregate(xml, "PartyName") { basic(xml, "Name", issuer.fetch("company_name")) }
          postal_address(xml, issuer.fetch("company_address"))
          aggregate(xml, "PartyTaxScheme") do
            basic(xml, "CompanyID", issuer.fetch("vat_id"))
            aggregate(xml, "TaxScheme") { basic(xml, "ID", "VAT") }
          end
          aggregate(xml, "PartyLegalEntity") { basic(xml, "RegistrationName", issuer.fetch("company_name")) }
          aggregate(xml, "Contact") do
            basic(xml, "Name", "Rechnungswesen")
            basic(xml, "Telephone", ENV.fetch("INVOICE_SENDER_PHONE", "+491623473520"))
            basic(xml, "ElectronicMail", ENV.fetch("INVOICE_SENDER_EMAIL", "info@zapfe.jetzt"))
          end
        end
      end
    end

    def customer_party(xml)
      recipient = @snapshot.fetch("recipient")
      aggregate(xml, "AccountingCustomerParty") do
        aggregate(xml, "Party") do
          basic(xml, "EndpointID", recipient.fetch("email"), "schemeID" => "EM")
          aggregate(xml, "PartyName") { basic(xml, "Name", recipient.fetch("name")) }
          postal_address(xml, recipient.fetch("address"))
          aggregate(xml, "PartyLegalEntity") { basic(xml, "RegistrationName", recipient.fetch("name")) }
        end
      end
    end

    def postal_address(xml, raw_address)
      lines = raw_address.to_s.lines.map(&:strip).reject(&:blank?)
      postcode, city = lines.last.to_s.match(/\A(\S+)\s+(.+)\z/)&.captures
      aggregate(xml, "PostalAddress") do
        basic(xml, "StreetName", lines[0...-1].join(", ").presence || lines.first)
        basic(xml, "CityName", city.presence || "NOTPROVIDED")
        basic(xml, "PostalZone", postcode.presence || "NOTPROVIDED")
        aggregate(xml, "Country") { basic(xml, "IdentificationCode", "DE") }
      end
    end

    def payment_means(xml)
      issuer = @snapshot.fetch("issuer")
      aggregate(xml, "PaymentMeans") do
        basic(xml, "PaymentMeansCode", "58")
        basic(xml, "PaymentID", @invoice.invoice_number)
        aggregate(xml, "PayeeFinancialAccount") do
          basic(xml, "ID", issuer.fetch("iban").to_s.delete(" "))
          basic(xml, "Name", issuer.fetch("company_name"))
          aggregate(xml, "FinancialInstitutionBranch") { basic(xml, "ID", issuer.fetch("bic")) }
        end
      end
    end

    def delivery(xml)
      return if @snapshot["delivery_on"].blank?

      aggregate(xml, "Delivery") { basic(xml, "ActualDeliveryDate", @snapshot.fetch("delivery_on")) }
    end

    def tax_total(xml)
      aggregate(xml, "TaxTotal") do
        basic(xml, "TaxAmount", decimal(@snapshot.dig("totals", "tax")), "currencyID" => "EUR")
        @snapshot.fetch("tax_breakdown").each do |entry|
          aggregate(xml, "TaxSubtotal") do
            basic(xml, "TaxableAmount", decimal(entry.fetch("taxable_basis")), "currencyID" => "EUR")
            basic(xml, "TaxAmount", decimal(entry.fetch("tax_amount")), "currencyID" => "EUR")
            tax_category(xml, entry.fetch("rate"))
          end
        end
      end
    end

    def allowance_charges(xml)
      @snapshot.fetch("tax_breakdown").each do |entry|
        next unless BigDecimal(entry.fetch("allowance_amount")).positive?

        aggregate(xml, "AllowanceCharge") do
          basic(xml, "ChargeIndicator", "false")
          basic(xml, "AllowanceChargeReason", @snapshot.dig("totals", "global_discount_reason").presence || "Rabatt")
          basic(xml, "Amount", decimal(entry.fetch("allowance_amount")), "currencyID" => "EUR")
          tax_category(xml, entry.fetch("rate"))
        end
      end
    end

    def monetary_total(xml)
      totals = @snapshot.fetch("totals")
      aggregate(xml, "LegalMonetaryTotal") do
        basic(xml, "LineExtensionAmount", decimal(totals.fetch("subtotal_net")), "currencyID" => "EUR")
        basic(xml, "AllowanceTotalAmount", decimal(totals.fetch("global_discount_amount")), "currencyID" => "EUR") if BigDecimal(totals.fetch("global_discount_amount")).positive?
        basic(xml, "TaxExclusiveAmount", decimal(totals.fetch("net")), "currencyID" => "EUR")
        basic(xml, "TaxInclusiveAmount", decimal(totals.fetch("gross")), "currencyID" => "EUR")
        basic(xml, "PayableAmount", decimal(totals.fetch("gross")), "currencyID" => "EUR")
      end
    end

    def document_lines(xml)
      @snapshot.fetch("line_items").each_with_index do |item, index|
        aggregate(xml, credit_note? ? "CreditNoteLine" : "InvoiceLine") do
          basic(xml, "ID", item["id"].presence || index + 1)
          basic(xml, credit_note? ? "CreditedQuantity" : "InvoicedQuantity", decimal(item.fetch("quantity")), "unitCode" => unit_code(item.fetch("unit")))
          basic(xml, "LineExtensionAmount", decimal(item.fetch("net_total")), "currencyID" => "EUR")
          aggregate(xml, "Item") do
            basic(xml, "Name", item.fetch("description"))
            aggregate(xml, "ClassifiedTaxCategory") { tax_category_contents(xml, item.fetch("tax_rate")) }
          end
          aggregate(xml, "Price") { basic(xml, "PriceAmount", decimal(item.fetch("net_unit_price")), "currencyID" => "EUR") }
        end
      end
    end

    def tax_category(xml, rate)
      aggregate(xml, "TaxCategory") { tax_category_contents(xml, rate) }
    end

    def tax_category_contents(xml, rate)
      basic(xml, "ID", BigDecimal(rate).zero? ? "Z" : "S")
      basic(xml, "Percent", decimal(rate))
      aggregate(xml, "TaxScheme") { basic(xml, "ID", "VAT") }
    end

    def decimal(value) = format("%.2f", BigDecimal(value.to_s))

    def unit_code(unit)
      { "Tag" => "DAY", "Stk" => "C62", "Stück" => "C62", "Std" => "HUR", "Stunde" => "HUR" }.fetch(unit, "C62")
    end

    def credit_note? = @snapshot.fetch("invoice_type") == "credit_note"
    def root_name = credit_note? ? "CreditNote" : "Invoice"
    def root_namespace = "urn:oasis:names:specification:ubl:schema:xsd:#{root_name}-2"
    def type_code_element = credit_note? ? "CreditNoteTypeCode" : "InvoiceTypeCode"
  end
end
