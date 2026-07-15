class Admin::InvoicesController < Admin::BaseController
  before_action :set_invoice, only: %i[show update finalize send_mail mark_paid document]

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
    redirect_to admin_invoice_path(@invoice), notice: "Rechnung wurde versendet."
  rescue Invoices::SendMail::NotSendable => error
    redirect_to admin_invoice_path(@invoice), alert: error.message
  end

  def mark_paid
    @invoice.update!(status: "paid", paid_at: Time.current)
    @invoice.activities.create!(admin_user: current_admin_user, event_type: "paid", message: "Rechnung #{@invoice.invoice_number} als bezahlt markiert")
    redirect_to admin_invoice_path(@invoice), notice: "Zahlungseingang erfasst."
  end

  def document
    return redirect_to(admin_invoice_path(@invoice), alert: "Für diesen Entwurf gibt es noch kein PDF.") unless @invoice.document.attached?

    send_data @invoice.document.download, filename: @invoice.document.filename.to_s, type: "application/pdf", disposition: "attachment"
  end

  private

  def set_invoice
    @invoice = Invoice.includes(:order, :offer, :line_items).find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:recipient_name, :recipient_email, :recipient_address, :delivery_on, :due_on, :global_discount_type, :global_discount_value, :global_discount_reason, :internal_note)
  end
end
