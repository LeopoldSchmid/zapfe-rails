module Admin::Undoable
  private

  def register_undo(record, attribute:, from:, path:)
    session[:admin_undo] = { "type" => record.class.name, "id" => record.id, "attribute" => attribute.to_s, "from" => from, "path" => path, "expires_at" => 30.seconds.from_now.to_i }
    flash[:undo_available] = true
  end
end
