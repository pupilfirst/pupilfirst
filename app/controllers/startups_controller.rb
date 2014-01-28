class StartupsController < InheritedResources::Base
	before_filter :authenticate_user!

	def index
		@startups = [current_user.startup]
	end

	def show
		@startup = Startup.find(params[:id])
		raise_not_found unless current_user.startup.try(:id) == @startup.id
	end

	def edit
		@startup = Startup.find(params[:id])
		raise_not_found unless current_user.startup.try(:id) == @startup.id
	end

	def destroy

	end

	def permitted_params
	  {:startup => params.fetch(:startup, {}).permit(:name, :pitch, :website, :about, :email, :phone, :logo, :facebook_link, :twitter_link, {category_ids: []})}
	end
end
