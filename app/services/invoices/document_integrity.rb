module Invoices
  class DocumentIntegrity
    IntegrityError = Class.new(StandardError)

    def self.verify!(invoice, kind: :pdf)
      attachment, expected = case kind
      when :pdf then [ invoice.document, invoice.document_sha256 ]
      when :xml then [ invoice.e_invoice, invoice.e_invoice_sha256 ]
      else raise ArgumentError, "Unbekannter Dokumenttyp"
      end

      raise IntegrityError, "Dokument oder gespeicherte Prüfsumme fehlt." unless attachment.attached? && expected.present?

      actual = Digest::SHA256.hexdigest(attachment.download)
      raise IntegrityError, "Dokumentintegrität verletzt; Versand und Download wurden gesperrt." unless ActiveSupport::SecurityUtils.secure_compare(actual, expected)

      true
    end
  end
end
