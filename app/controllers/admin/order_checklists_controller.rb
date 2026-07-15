class Admin::OrderChecklistsController < Admin::BaseController
  before_action :set_order

  def create
    template = ChecklistTemplate.active.find(params.require(:checklist_template_id))
    checklist = @order.checklists.create!(
      checklist_template: template,
      name: template.name,
      section: template.section
    )
    template.items.order(:position, :id).find_each do |item|
      copy = checklist.items.create!(
        checklist_template_item: item, title: item.title, instructions: item.instructions,
        link_url: item.link_url, video_url: item.video_url, notes: item.notes, position: item.position
      )
      copy.attachment.attach(item.attachment.blob) if item.attachment.attached?
    end
    redirect_to execution_admin_order_path(@order), notice: "Checkliste hinzugefügt."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => error
    redirect_to execution_admin_order_path(@order), alert: error.message
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end
end
