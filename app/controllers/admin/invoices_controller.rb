class Admin::InvoicesController < Admin::BaseController
  before_action :set_invoice, only: %i[show update finalize send_mail cancel mark_paid document e_invoice]

  def index
    @order = Order.includes(invoices: :offer).find(params[:order_id])
    @accepted_offers = @order.offers.where(status: "accepted").order(version: :desc)
  end

  def create
    order = Order.find(params[:order_id])
    offer = order.offers.find(params.require(:offer_id))
    invoice = Invoices::CreateFromOffer.new(offer:, admin_user: current_admin_user).call
    redirect_to admin_invoice_path(invoice), notice: "Rechnungsentwurf erstellt."
  rescue Invoices::CreateFromOffer::NotCreatable => error
    redirect_to admin_order_invoices_path(order), alert: error.message
  end

  def show
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to admin_invoice_path(@invoice), notice: "Rechnungsentwurf aktualisiert."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def finalize
    Invoices::Finalize.new(invoice: @invoice, admin_user: current_admin_user).call
    redirect_to admin_invoice_path(@invoice), notice: "Rechnung #{@invoice.invoice_number} finalisiert."
  rescue Invoices::Finalize::NotFinalizable => error
    redirect_to admin_invoice_path(@invoice), alert: error.message
  end

  def send_mail
    Invoices::SendMail.new(invoice: @invoice, admin_user: current_admin_user).call
    redirect_to admin_invoice_path(@invoice), notice: "Rechnung wurde für den Versand eingereiht."
  rescue Invoices::SendMail::NotSendable => error
    redirect_to admin_invoice_path(@invoice), alert: error.message
  end

  def mark_paid
    @invoice.update!(status: "paid", paid_at: Time.current)
    @invoice.activities.create!(admin_user: current_admin_user, event_type: "paid", message: "Rechnung #{@invoice.invoice_number} als bezahlt markiert")
    redirect_to admin_invoice_path(@invoice), notice: "Zahlungseingang erfasst."
  end

  def cancel
    credit_note = Invoices::Cancel.new(invoice: @invoice, admin_user: current_admin_user, reason: params[:reason]).call
    redirect_to admin_invoice_path(credit_note), notice: "Stornorechnung #{credit_note.invoice_number} wurde finalisiert."
  rescue Invoices::Cancel::NotCancellable => error
    redirect_to admin_invoice_path(@invoice), alert: error.message
  end

  def document
    return redirect_to(admin_invoice_path(@invoice), alert: "Für diesen Entwurf gibt es noch kein PDF.") unless @invoice.document.attached?

    Invoices::DocumentIntegrity.verify!(@invoice, kind: :pdf)
    send_data @invoice.document.download, filename: @invoice.document.filename.to_s, type: "application/pdf", disposition: "attachment"
  rescue Invoices::DocumentIntegrity::IntegrityError => error
    redirect_to admin_invoice_path(@invoice), alert: error.message
  end

  def e_invoice
    return redirect_to(admin_invoice_path(@invoice), alert: "Für diesen Entwurf gibt es noch keine E-Rechnung.") unless @invoice.e_invoice.attached?

    Invoices::DocumentIntegrity.verify!(@invoice, kind: :xml)
    send_data @invoice.e_invoice.download, filename: @invoice.e_invoice.filename.to_s, type: "application/xml", disposition: "attachment"
  rescue Invoices::DocumentIntegrity::IntegrityError => error
    redirect_to admin_invoice_path(@invoice), alert: error.message
  end

  private

  def set_invoice
    @invoice = Invoice.includes(:order, :offer, :line_items).find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:recipient_name, :recipient_email, :recipient_address, :delivery_on, :due_on, :global_discount_type, :global_discount_value, :global_discount_reason, :internal_note)
  end
end
