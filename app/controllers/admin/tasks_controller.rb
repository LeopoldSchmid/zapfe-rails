class Admin::TasksController < Admin::BaseController
  before_action :set_order
  before_action :set_task, only: %i[update destroy]

  def create
    @task = @order.tasks.build(task_params)
    if @task.save
      redirect_to execution_admin_order_path(@order), notice: "Aufgabe hinzugefügt."
    else
      redirect_to execution_admin_order_path(@order), alert: @task.errors.full_messages.to_sentence
    end
  end

  def update
    if @task.update(task_params)
      redirect_to execution_admin_order_path(@order), notice: "Aufgabe aktualisiert."
    else
      redirect_to execution_admin_order_path(@order), alert: @task.errors.full_messages.to_sentence
    end
  end

  def destroy
    @task.destroy!
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
end
