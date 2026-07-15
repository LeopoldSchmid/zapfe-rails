class Orders::ApplyTemplate
  def initialize(order:, template:)
    @order = order
    @template = template
  end

  def apply_defaults!
    %i[event_type event_location guests customer_message next_step starts_on ends_on start_time end_time responsible_admin_user_id].each do |attribute|
      next if %i[starts_on ends_on].include?(attribute)

      @order.public_send("#{attribute}=", @template.public_send(attribute)) if @order.public_send(attribute).blank?
    end
    @order
  end

  def materialize!
    @order.transaction do
      @order.tags = @template.tags
      @template.product_variants.find_each do |variant|
        @order.product_selections.create!(product_variant: variant, quantity: 1, unit: "Stk")
      end
      @template.template_tasks.order(:position, :id).find_each do |template_task|
        @order.tasks.create!(
          assigned_admin_user: template_task.assigned_admin_user || @order.responsible_admin_user,
          title: template_task.title,
          details: template_task.details,
          status: "open",
          relative_anchor: "event_date",
          relative_offset_days: template_task.relative_offset_days
        )
      end
      if @order.next_step.present?
        @order.tasks.create!(
          assigned_admin_user: @order.responsible_admin_user,
          title: @order.next_step,
          status: "open",
          due_on: @order.next_step_due_on
        )
      end
      @template.checklist_templates.active.find_each { |template| copy_checklist(template) }
      reserve_resources!
    end
  end

  private

  def copy_checklist(template)
    checklist = @order.checklists.create!(checklist_template: template, name: template.name, section: template.section)
    template.items.order(:position, :id).find_each do |item|
      copy = checklist.items.create!(checklist_template_item: item, title: item.title, instructions: item.instructions,
        link_url: item.link_url, video_url: item.video_url, notes: item.notes, position: item.position)
      copy.attachment.attach(item.attachment.blob) if item.attachment.attached?
    end
  end

  def reserve_resources!
    return if @order.event_date.blank? || @order.start_time.blank? || @order.end_time.blank?

    starts_at = Time.zone.parse("#{@order.event_date} #{@order.start_time}")
    ends_at = Time.zone.parse("#{@order.event_date} #{@order.end_time}")
    @template.resources.active.find_each do |resource|
      @order.reservations.create!(resource: resource, starts_at: starts_at, ends_at: ends_at, note: "Aus Vorlage #{@template.name}")
    end
  end
end
