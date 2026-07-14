class Admin::ChecklistTemplatesController < Admin::BaseController
  before_action :set_template, only: %i[edit update]

  def index
    @checklist_templates = ChecklistTemplate.includes(:items).order(:resource_type, :section, :name)
  end

  def new
    @checklist_template = ChecklistTemplate.new(active: true)
    3.times { @checklist_template.items.build }
  end

  def create
    @checklist_template = ChecklistTemplate.new(template_params)
    if @checklist_template.save
      redirect_to admin_checklist_templates_path, notice: "Checklistenvorlage angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @checklist_template.items.build if @checklist_template.items.empty?
  end

  def update
    if @checklist_template.update(template_params)
      redirect_to admin_checklist_templates_path, notice: "Checklistenvorlage aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_template
    @checklist_template = ChecklistTemplate.find(params[:id])
  end

  def template_params
    params.require(:checklist_template).permit(:name, :resource_type, :section, :active,
      items_attributes: %i[id title instructions link_url video_url notes position attachment _destroy])
  end
end
