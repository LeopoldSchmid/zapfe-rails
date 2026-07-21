class Admin::BaseController < ApplicationController
  include Admin::Undoable
  OWNER_ONLY_CONTROLLERS = %w[admin_users system_settings].freeze
  MANAGEMENT_CONTROLLERS = %w[
    categories checklist_templates events help_articles order_templates
    procurement_profiles products resources supplier_offerings suppliers
  ].freeze
  OPERATIONAL_CONTROLLERS = %w[
    customers dashboard help_requests inquiries invoices offer_line_items offers
    order_checklist_items order_checklists order_time_entries orders
    procurement_plans push_subscriptions reservations tasks time_entries undo
  ].freeze

  before_action :require_admin!
  before_action :authorize_admin_role!
  layout "admin"

  helper_method :admin_authorized_for?

  private

  def paginate(scope, per_page: 50)
    page = [ params[:page].to_i, 1 ].max
    rows = scope.offset((page - 1) * per_page).limit(per_page + 1).to_a
    @pagination = { page: page, previous: page > 1, next: rows.length > per_page }
    rows.first(per_page)
  end

  def authorize_admin_role!
    return if admin_authorized_for?(controller_name)

    AdminSecurity::Audit.log(event_type: :authorization_denied, actor: current_admin_user, target: current_admin_user, request: request, metadata: { reason: controller_name })
    head :forbidden
  end

  def admin_authorized_for?(target_controller)
    return false unless current_admin_user
    return true if current_admin_user.owner?
    return false if OWNER_ONLY_CONTROLLERS.include?(target_controller.to_s)
    return true if current_admin_user.admin? && MANAGEMENT_CONTROLLERS.include?(target_controller.to_s)

    OPERATIONAL_CONTROLLERS.include?(target_controller.to_s)
  end
end
