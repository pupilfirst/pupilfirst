class StartupsController < InheritedResources::Base
	before_filter :authenticate_user!
	skip_before_filter :authenticate_user!, only: [:confirm_employee]
	after_filter only: [:create] do
		@startup.founders << current_user
		@startup.save
	end

	def index
		@current_user = current_user
		if current_user.startup.present?
			redirect_to action: :show, id: current_user.startup.id
		else
			redirect_to action: :new
		end
	end

	def create
		@startup = Startup.create(apply_now_params)
		@startup.full_validation = false
		@startup.founders << current_user
		redirect_to(action: :show, id: @startup.id) if @startup.save
	end

	def show
		@startup = Startup.find(params[:id])
		raise_not_found unless current_user.startup.try(:id) == @startup.id
	end

	def edit
		@startup = Startup.find(params[:id])
		raise_not_found unless current_user.startup.try(:id) == @startup.id
	end

	def confirm_employee
		@startup = Startup.find(params[:id])
		@new_employee = User.find_by_startup_verifier_token(params[:token])
		raise_not_found unless @new_employee
		if request.post?
			flash[:message] = "User was already accepted as startup employee." if @new_employee.startup_link_verifier_id
			@new_employee.confirm_employee! params[:is_founder]
			render :confirm_employee_done
		else
			@token = params[:token]
			render :confirm_employee
		end
	end

	def apply_now_params
    params.require(:startup).permit(:name, :phone, :pitch, :website, :email)
	end

	def permitted_params
	  {:startup => params.fetch(:startup, {}).permit(:name, :address, :pitch, :website, :about, :email, :phone, :logo,
	                                                 :remote_logo_url, :facebook_link, :twitter_link, :pre_funds,
	                                                 :help_from_sv, {category_ids: []},
	                                                 {startup_before: [:startup_name, :startup_descripition] }
                                                 	)}
	end
end
