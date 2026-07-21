class Admin::ResourcesController < Admin::BaseController
  before_action :set_resource, only: %i[edit update]

  def index
    @resources = Resource.order(:resource_type, :name).to_a
    @calendar_start = parse_calendar_start
    @calendar_days = (@calendar_start...(@calendar_start + 7.days)).to_a
    @calendar_reservations = Reservation.includes(:resource, :order)
      .where("starts_at < ? AND ends_at >= ?", (@calendar_start + 7.days).beginning_of_day, @calendar_start.beginning_of_day)
      .order(:starts_at)
      .to_a
    @calendar_reservations_by_cell = @calendar_reservations.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |reservation, index|
      @calendar_days.each do |day|
        index[[ reservation.resource_id, day ]] << reservation if reservation.starts_at.to_date <= day && reservation.ends_at.to_date >= day
      end
    end
    @upcoming_reservations_by_resource = Reservation.includes(:order)
      .where(resource_id: @resources.map(&:id), ends_at: Time.current..)
      .order(:starts_at)
      .group_by(&:resource_id)
      .transform_values { |reservations| reservations.first(3) }
  end

  def new
    @resource = Resource.new(active: true)
  end

  def create
    @resource = Resource.new(resource_params)
    if @resource.save
      redirect_to admin_resources_path, notice: "Ressource angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @resource.update(resource_params)
      redirect_to admin_resources_path, notice: "Ressource aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def resource_params
    params.require(:resource).permit(:name, :resource_type, :active, :configuration_notes, :rental_position_name, :rental_net_price, :rental_unit)
  end

  def parse_calendar_start
    Date.iso8601(params[:week]).beginning_of_week
  rescue ArgumentError, TypeError
    Date.current.beginning_of_week
  end
end
