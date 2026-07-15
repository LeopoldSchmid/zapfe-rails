class Admin::HelpRequestsController < Admin::BaseController
  def create
    article = HelpArticle.find_by(topic: request_params[:topic])
    help_request = current_admin_user.help_requests.build(request_params.merge(help_article: article))

    if help_request.save
      redirect_back fallback_location: admin_root_path, notice: "Frage gesendet."
    else
      redirect_back fallback_location: admin_root_path, alert: help_request.errors.full_messages.to_sentence
    end
  end

  def update
    help_request = HelpRequest.find(params[:id])
    help_request.update!(status: params.require(:help_request).permit(:status)[:status])
    redirect_back fallback_location: admin_help_articles_path, notice: "Frage aktualisiert."
  end

  private

  def request_params
    params.require(:help_request).permit(:topic, :page_path, :subject, :message, :screenshot)
  end
end
