class StartupsController < InheritedResources::Base
	before_filter :authenticate_user!
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

	def permitted_params
	  {:startup => params.fetch(:startup, {}).permit(:name, :pitch, :website, :about, :email, :phone, :logo, :facebook_link, :twitter_link, {category_ids: []})}
	end
end
