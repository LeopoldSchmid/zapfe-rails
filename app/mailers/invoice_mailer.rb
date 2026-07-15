class InvoiceMailer < ApplicationMailer
  def invoice(invoice)
    @invoice = invoice
    attachments[@invoice.document.filename.to_s] = { mime_type: @invoice.document.content_type, content: @invoice.document.download }

    mail(to: @invoice.recipient_email, subject: "Rechnung #{@invoice.invoice_number} von Zapfe")
  end
end
