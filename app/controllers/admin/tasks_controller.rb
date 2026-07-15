class Admin::TasksController < Admin::BaseController
  before_action :set_order
  before_action :set_task, only: %i[update destroy]

  def create
    @task = @order.tasks.build(task_params)
    if @task.save
      @order.activities.create!(admin_user: current_admin_user, event_type: "task_created", message: "Aufgabe angelegt: #{@task.title}", metadata: { task_id: @task.id, due_on: @task.due_on })
      notify_assignee(@task) if @task.assigned_admin_user_id.present? && @task.assigned_admin_user_id != current_admin_user.id
      redirect_to execution_admin_order_path(@order), notice: "Aufgabe hinzugefügt."
    else
      redirect_to execution_admin_order_path(@order), alert: @task.errors.full_messages.to_sentence
    end
  end

  def update
    previous_status = @task.status
    if @task.update(task_params)
      changes = @task.previous_changes.slice("title", "details", "status", "due_on", "assigned_admin_user_id").except("updated_at")
      if changes.present?
        @order.activities.create!(admin_user: current_admin_user, event_type: "task_updated", message: "Aufgabe aktualisiert: #{@task.title}", metadata: { task_id: @task.id, changes: changes })
      end
      notify_assignee(@task) if @task.saved_change_to_assigned_admin_user_id? && @task.assigned_admin_user_id.present? && @task.assigned_admin_user_id != current_admin_user.id
      register_undo(@task, attribute: :status, from: previous_status, path: execution_admin_order_path(@order)) if @task.saved_change_to_status?
      redirect_to execution_admin_order_path(@order), notice: "Aufgabe aktualisiert."
    else
      redirect_to execution_admin_order_path(@order), alert: @task.errors.full_messages.to_sentence
    end
  end

  def destroy
    task_title = @task.title
    @task.destroy!
    @order.activities.create!(admin_user: current_admin_user, event_type: "task_deleted", message: "Aufgabe entfernt: #{task_title}")
    redirect_to execution_admin_order_path(@order), notice: "Aufgabe entfernt."
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_task
    @task = @order.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:assigned_admin_user_id, :title, :details, :status, :due_on, :relative_anchor, :relative_offset_days)
  end

  def notify_assignee(task)
    return unless PushNotifications::SendNotification.configured?

    task.assigned_admin_user.push_subscriptions.find_each do |subscription|
      PushNotificationJob.perform_later(
        subscription,
        title: "Neue Aufgabe",
        body: "#{task.order.customer_name}: #{task.title}",
        path: execution_admin_order_path(task.order, anchor: "task-#{task.id}"),
        tag: "task-#{task.id}"
      )
    end
  end
end
