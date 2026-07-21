class InvoiceMailer < ApplicationMailer
  def invoice(invoice, delivery_id: nil)
    @invoice = invoice
    attachments[@invoice.document.filename.to_s] = { mime_type: @invoice.document.content_type, content: @invoice.document.download }
    attachments[@invoice.e_invoice.filename.to_s] = { mime_type: @invoice.e_invoice.content_type, content: @invoice.e_invoice.download }

    headers["Message-ID"] = DocumentDelivery.find(delivery_id).stable_message_id if delivery_id
    document_name = @invoice.invoice_type == "credit_note" ? "Stornorechnung" : "Rechnung"
    mail(to: @invoice.recipient_email, subject: "#{document_name} #{@invoice.invoice_number} von Zapfe")
  end
end
