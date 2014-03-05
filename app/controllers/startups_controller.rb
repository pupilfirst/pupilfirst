class StartupsController < InheritedResources::Base
	before_filter :authenticate_user!
	skip_before_filter :authenticate_user!, only: [:confirm_employee]
	after_filter only: [:create] do
		@startup.founders << current_user
		@startup.save!
	end

	def index
		@current_user = current_user
		@startups = current_user.startup.present? ? [current_user.startup] : []
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
		raise_not_found unless current_user.startup.try(:id) == @startup.id
		@new_employee = User.find_by_startup_verifier_token(params[:token])
		@new_employee.update_attributes!(startup_link_verifier: current_user)
		render text: 'done', status: :created
	end

	def permitted_params
	  {:startup => params.fetch(:startup, {}).permit(:name, :pitch, :website, :about, :email, :phone, :logo, :remote_logo_url, :facebook_link, :twitter_link, {category_ids: []})}
	end
end
