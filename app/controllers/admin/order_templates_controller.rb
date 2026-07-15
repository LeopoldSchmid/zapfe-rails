class Admin::OrderTemplatesController < Admin::BaseController
  before_action :set_template, only: %i[edit update create_series]
  before_action :load_form_data, only: %i[new create edit update]

  def index
    @order_templates = OrderTemplate.includes(:tags, :resources, :template_tasks, :checklist_templates).order(:name)
  end

  def new
    @order_template = OrderTemplate.new(active: true)
    @order_template.template_tasks.build
  end

  def create
    @order_template = OrderTemplate.new(template_params)
    if @order_template.save
      @order_template.persist_tags!
      redirect_to admin_order_templates_path, notice: "Auftragsvorlage angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @order_template.template_tasks.build if @order_template.template_tasks.empty?
  end

  def update
    if @order_template.update(template_params)
      @order_template.persist_tags!
      redirect_to admin_order_templates_path, notice: "Auftragsvorlage aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create_series
    orders = Orders::CreateSeriesFromTemplate.new(
      template: @order_template,
      start_on: series_params[:start_on],
      weekday: series_params[:weekday],
      occurrences: series_params[:occurrences],
      admin_user: current_admin_user
    ).call
    redirect_to admin_orders_path, notice: "#{orders.count} Termine für #{@order_template.name} erstellt."
  rescue Orders::CreateSeriesFromTemplate::NotCreatable => error
    redirect_to admin_order_templates_path, alert: error.message
  end

  private

  def set_template
    @order_template = OrderTemplate.find(params[:id])
  end

  def load_form_data
    @admin_users = AdminUser.active.order(:name)
    @resources = Resource.active.order(:resource_type, :name)
    @product_variants = ProductVariant.includes(:product).order("products.brand", "products.name", :size).references(:product)
    @checklist_templates = ChecklistTemplate.active.order(:resource_type, :section, :name)
  end

  def template_params
    params.require(:order_template).permit(:name, :active, :responsible_admin_user_id, :event_type, :event_location,
      :guests, :customer_message, :next_step, :skip_offer, :starts_on, :ends_on, :start_time, :end_time, :tag_names,
      resource_ids: [], product_variant_ids: [], checklist_template_ids: [],
      template_tasks_attributes: %i[id title details assigned_admin_user_id relative_offset_days position _destroy])
  end

  def series_params
    params.require(:series).permit(:start_on, :weekday, :occurrences)
  end
end
