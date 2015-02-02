class NewsController < ApplicationController
  def new
    @news = News.new
  end

  def create
    @news = News.new news_params
    if @news.save
      redirect_to news_index_path
    else
      render new_news_path
    end
  end

  def show
  end

  def index
    @news = News.all
  end

  private
  def news_params
    params.require(:news).permit(:title, :picture, :published_at, :featured, :body)
  end
end
