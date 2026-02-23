class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: %i[edit update destroy]

  def index
    @events = Event.order(date_from: :asc, position: :asc, created_at: :desc)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to admin_events_path, notice: "Event erstellt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to admin_events_path, notice: "Event aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_events_path, notice: "Event gelöscht."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title,
      :subtitle,
      :description,
      :date_from,
      :date_to,
      :location,
      :instagram_url,
      :position,
      :published,
      :image
    )
  end
end
