class Admin::AdminUsersController < Admin::BaseController
  before_action :set_admin_user, only: %i[edit update reset_mfa]

  def index
    @admin_users = AdminUser.order(:name, :email)
  end

  def new
    @admin_user = AdminUser.new(active: true, role: :member)
  end

  def create
    attributes = admin_user_params
    attributes[:role] = requested_role.presence || "member"
    @admin_user = AdminUser.new(attributes)

    if @admin_user.save
      AdminSecurity::Audit.log(event_type: :admin_user_created, actor: current_admin_user, target: @admin_user, request: request, metadata: { changed_fields: %w[name email role active] })
      redirect_to admin_admin_users_path, notice: "Internes Konto erstellt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    previous_security_state = @admin_user.slice("email", "role", "active", "password_digest")
    attributes = admin_user_params
    attributes[:role] = requested_role if requested_role.present?
    if @admin_user.update(attributes)
      changed_fields = previous_security_state.keys.select { |key| previous_security_state[key] != @admin_user.public_send(key) }
      AdminSecurity::Audit.log(event_type: :admin_user_updated, actor: current_admin_user, target: @admin_user, request: request, metadata: { changed_fields: changed_fields })
      reset_session if @admin_user == current_admin_user && changed_fields.any?
      redirect_to admin_admin_users_path, notice: "Internes Konto aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def reset_mfa
    @admin_user.reset_mfa!
    AdminSecurity::Audit.log(event_type: :mfa_reset, actor: current_admin_user, target: @admin_user, request: request)
    reset_session if @admin_user == current_admin_user
    redirect_to admin_admin_users_path, notice: "MFA wurde zurückgesetzt. Beim nächsten Login ist eine neue Einrichtung erforderlich."
  end

  private

  def set_admin_user
    @admin_user = AdminUser.find(params[:id])
  end

  def admin_user_params
    permitted = [ :name, :email, :phone, :email_signature, :active, :password, :password_confirmation ]
    params.require(:admin_user).permit(*permitted)
  end

  # Role assignment is intentionally explicit and remains protected by the
  # owner-only controller policy plus AdminUser's closed enum validation.
  def requested_role
    params.require(:admin_user)[:role]
  end
end
