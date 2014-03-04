class V1::NewsController < V1::BaseController

  skip_before_filter :require_token, only: [:index, :show]

	def index
		category = Category.find_by_name(params['category']) rescue nil
		clause = category ? ["category_id = ?", category.id] : nil
    @news = News.where(clause).order('published_at desc').limit(50)
    @news = @news.select{|e| e.featured } + @news.reject{|e| e.featured }
    respond_to do |format|
        format.json
    end
	end

	def show
		@news = News.find(params[:id])
		respond_to do |f|
			f.json
		end
	end
end
