class V1::StartupsController < V1::BaseController

	def index
		category = Category.startup_category.find_by_name(params['category']) rescue nil
		clause = category ? ["category_id = ?", category.id] : nil
		@startups = if params[:search_term]
				Startup.fuzzy_search(name: params[:search_term])
			else
				Startup.joins(:categories).where(clause).order("id desc").uniq
			end
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

	def load_suggestions
	  @suggestions = Startup.where("name like ?", "#{params[:term]}%")
	end

end
