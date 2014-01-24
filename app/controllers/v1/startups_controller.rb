class V1::StartupsController < V1::BaseController

	def index
		category = Category.startup_category.find_by_name(params['category']) rescue nil
		clause = category ? ["category_id = ?", category.id] : nil
    @startups = Startup.where(clause)
    @startups = @startups*30
    respond_to do |format|
        format.json
    end
	end


	def show
		@startup = Startup.find(params[:id])
		respond_to do |f|
			f.json
		end
	end
end
