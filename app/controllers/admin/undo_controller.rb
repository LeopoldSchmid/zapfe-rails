class Admin::UndoController < Admin::BaseController
  def create
    action = session.delete(:admin_undo)
    return redirect_to(admin_root_path, alert: "Diese Änderung kann nicht mehr rückgängig gemacht werden.") if action.blank? || action.fetch("expires_at", 0).to_i < Time.current.to_i

    record = action.fetch("type").constantize.find(action.fetch("id"))
    record.update!(action.fetch("attribute") => action.fetch("from"))
    redirect_to action.fetch("path"), notice: "Änderung rückgängig gemacht."
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    redirect_to admin_root_path, alert: "Diese Änderung kann nicht mehr rückgängig gemacht werden."
  end
end
