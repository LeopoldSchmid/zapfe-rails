class Admin::AdminUsersController < Admin::BaseController
  before_action :set_admin_user, only: %i[edit update]

  def index
    @admin_users = AdminUser.order(:name, :email)
  end

  def new
    @admin_user = AdminUser.new(active: true)
  end

  def create
    @admin_user = AdminUser.new(admin_user_params)

    if @admin_user.save
      redirect_to admin_admin_users_path, notice: "Internes Konto erstellt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @admin_user.update(admin_user_params)
      reset_session if @admin_user == current_admin_user && !@admin_user.active?
      redirect_to admin_admin_users_path, notice: "Internes Konto aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_admin_user
    @admin_user = AdminUser.find(params[:id])
  end

  def admin_user_params
    permitted = [ :name, :email, :phone, :email_signature, :active, :password, :password_confirmation ]
    params.require(:admin_user).permit(*permitted)
  end
end
