class Admin::CustomersController < Admin::BaseController
  before_action :set_customer, only: %i[edit update contact_options]

  def index
    @customers = Customer.includes(:contacts).order(:name)
  end

  def new
    @customer = Customer.new
    @customer.contacts.build(primary: true)
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      redirect_to admin_customers_path, notice: "Kunde angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @customer.contacts.build
  end

  def update
    if @customer.update(customer_params)
      redirect_to admin_customers_path, notice: "Kunde aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def contact_options
    render json: @customer.contacts.order(primary: :desc, name: :asc).map { |contact| { id: contact.id, label: contact.name, email: contact.email, phone: contact.phone, primary: contact.primary? } }
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :notes, contacts_attributes: %i[id name role email phone primary _destroy])
  end
end
