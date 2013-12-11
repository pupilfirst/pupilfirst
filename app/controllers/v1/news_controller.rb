class V1::NewsController < V1::BaseController

	def index
    @news = News.last(50).sort_by {|n| n.featured ? 1 : 2}
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
