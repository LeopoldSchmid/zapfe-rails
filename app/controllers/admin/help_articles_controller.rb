class Admin::HelpArticlesController < Admin::BaseController
  before_action :set_help_article, only: %i[edit update]

  def index
    @help_articles = HelpArticle.includes(:faqs).order(:title)
  end

  def new
    @help_article = HelpArticle.new
    2.times { @help_article.faqs.build }
  end

  def create
    @help_article = HelpArticle.new(help_article_params)
    if @help_article.save
      redirect_to admin_help_articles_path, notice: "Anleitung angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    2.times { @help_article.faqs.build }
    @help_requests = @help_article.help_requests.includes(:admin_user, screenshot_attachment: :blob).order(created_at: :desc)
  end

  def update
    if @help_article.update(help_article_params)
      redirect_to admin_help_articles_path, notice: "Anleitung aktualisiert."
    else
      @help_requests = @help_article.help_requests.includes(:admin_user, screenshot_attachment: :blob).order(created_at: :desc)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_help_article
    @help_article = HelpArticle.find(params[:id])
  end

  def help_article_params
    params.require(:help_article).permit(:topic, :title, :body,
      faqs_attributes: %i[id question answer position _destroy])
  end
end
