class V1::NewsController < V1::BaseController

	def index
    @news = News.order('created_at desc').limit(50)
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
