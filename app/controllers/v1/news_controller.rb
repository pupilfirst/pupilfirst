class V1::NewsController < V1::BaseController

	def index
    @news = News.all
    @news = @news * 4
    respond_to do |format|
        format.json
    end
	end
end
