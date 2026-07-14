class Admin::PasswordsController < ApplicationController
  layout "admin_auth"
  before_action :set_admin_by_token, only: %i[edit update]

  def new
  end

  def create
    if (admin_user = AdminUser.find_by(email: params[:email]&.downcase&.strip))
      AdminUserMailer.password_reset(admin_user).deliver_later
    end

    redirect_to admin_login_path, notice: "Wenn ein Admin mit dieser E-Mail existiert, wurde ein Reset-Link versendet."
  end

  def edit
  end

  def update
    if @admin_user.update(password_params)
      redirect_to admin_login_path, notice: "Passwort aktualisiert. Du kannst dich jetzt anmelden."
    else
      flash.now[:alert] = @admin_user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_admin_by_token
    @admin_user = AdminUser.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to admin_new_password_path, alert: "Der Reset-Link ist ungültig oder abgelaufen."
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end
end
