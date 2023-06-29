class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    article = Article.find(params[:id])
    session[:page_views] ||= 0 
    session[:page_views] += 1

    if session[:page_views] < 3 
      render json: {
        id: article.id,
        title: article.title,
        minutes_to_read: article.minutes_to_read,
        author: article.author,
        content: article.content
      }
    else 
      render json: { error: "Maximum pageview limit reached" }, status: :unauthorized
    end
  end

  private

  def record_not_found(exception)
    render json: { error: "Article not found" }, status: :not_found
  end
end
