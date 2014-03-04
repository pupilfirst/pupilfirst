class V1::StartupsController < V1::BaseController

  skip_before_filter :require_token, only: [:index, :show, :load_suggestions]

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

	def create
		@current_user = current_user
		raise "User(#{current_user.fullname}) is already linked to startup #{current_user.startup.name}" if current_user.startup
  	startup = Startup.create(startup_params.merge({
  		email: current_user.email,
  		founders: [@current_user]
		}))
		@current_user.verify_self!
		@current_user.update_attributes!(is_founder: true)
		startup.save(validate: false)
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

	def link_employee
		@new_employee = current_user
		@new_employee.update_attributes!(startup: Startup.find(params[:id]), startup_link_verifier_id: nil, title: params[:position])
		StartupMailer.respond_to_new_employee(Startup.find(params[:id]), @new_employee).deliver
		# render nothing: true, status: :created
	end

private
  def startup_params
    params.require(:startup).permit(:name, :phone, :pitch, :website)
  end

end
