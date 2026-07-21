module Invoices
  class XrechnungValidator
    InvalidDocument = Class.new(StandardError)
    NS = {
      "ubl" => "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2",
      "cn" => "urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2",
      "cac" => "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2",
      "cbc" => "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    }.freeze

    def initialize(xml)
      @document = Nokogiri::XML(xml) { |config| config.strict.nonet }
    rescue Nokogiri::XML::SyntaxError => error
      raise InvalidDocument, error.message
    end

    def validate!
      root = credit_note? ? "/cn:CreditNote" : "/ubl:Invoice"
      type_code = credit_note? ? "CreditNoteTypeCode" : "InvoiceTypeCode"
      line = credit_note? ? "CreditNoteLine" : "InvoiceLine"
      required_paths = [
        "#{root}/cbc:CustomizationID", "#{root}/cbc:ProfileID", "#{root}/cbc:ID",
        "#{root}/cbc:IssueDate", "#{root}/cbc:#{type_code}", "#{root}/cbc:DocumentCurrencyCode",
        "#{root}/cbc:BuyerReference", "#{root}/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID",
        "#{root}/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID", "#{root}/cac:TaxTotal/cbc:TaxAmount",
        "#{root}/cac:LegalMonetaryTotal/cbc:PayableAmount", "#{root}/cac:#{line}"
      ]
      missing = required_paths.reject { |path| @document.at_xpath(path, NS)&.text&.present? }
      raise InvalidDocument, "Fehlende XRechnung-Felder: #{missing.join(", ")}" if missing.any?

      validate_totals!
      true
    end

    private

    def validate_totals!
      line_name = credit_note? ? "CreditNoteLine" : "InvoiceLine"
      line_total = @document.xpath("//cac:#{line_name}/cbc:LineExtensionAmount", NS).sum { |node| BigDecimal(node.text) }
      declared_line_total = decimal_at("//cac:LegalMonetaryTotal/cbc:LineExtensionAmount")
      tax = decimal_at("//cac:TaxTotal/cbc:TaxAmount")
      net = decimal_at("//cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount")
      gross = decimal_at("//cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount")
      payable = decimal_at("//cac:LegalMonetaryTotal/cbc:PayableAmount")

      raise InvalidDocument, "Positionssumme stimmt nicht" unless line_total.round(2) == declared_line_total.round(2)
      raise InvalidDocument, "Steuer-/Bruttosumme stimmt nicht" unless (net + tax).round(2) == gross.round(2)
      raise InvalidDocument, "Zahlbetrag stimmt nicht" unless payable.round(2) == gross.round(2)
    end

    def decimal_at(path)
      BigDecimal(@document.at_xpath(path, NS)&.text.to_s)
    rescue ArgumentError
      raise InvalidDocument, "Ungültiger Dezimalwert bei #{path}"
    end

    def credit_note?
      @document.root&.namespace&.href == NS.fetch("cn")
    end
  end
end
