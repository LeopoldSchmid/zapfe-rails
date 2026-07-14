class Admin::ResourcesController < Admin::BaseController
  before_action :set_resource, only: %i[edit update]

  def index
    @resources = Resource.includes(reservations: :order).order(:resource_type, :name)
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
    params.require(:resource).permit(:name, :resource_type, :active, :configuration_notes)
  end
end
