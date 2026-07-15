class Admin::DashboardController < Admin::BaseController
  def index
    @products_count = Product.count
    @events_count = Event.count
    @inquiries_count = Inquiry.count
    @unassigned_inquiries = Inquiry.where(assigned_admin_user_id: nil).where.not(status: %w[closed discarded]).order(created_at: :desc)
    @due_inquiries = Inquiry.where.not(next_step_due_on: nil).where.not(status: %w[closed discarded]).where(next_step_due_on: ..7.days.from_now.to_date).order(:next_step_due_on)
    @waiting_inquiries = Inquiry.where(status: %w[waiting_customer waiting_external]).where(archived_at: nil).order(:next_step_due_on, created_at: :desc)
    @upcoming_orders = Order.where(event_date: Date.current..).order(:event_date).limit(8)
    @due_tasks = Task.where.not(status: "done").where.not(due_on: nil).includes(:order, :assigned_admin_user).where(due_on: ..7.days.from_now.to_date).order(:due_on).limit(12)
  end
end
