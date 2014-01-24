class StartupsController < InheritedResources::Base
	before_filter :authenticate_user!

	def permitted_params
	  {:startup => params.fetch(:startup, {}).permit(:name, :pitch, :website, :about, :email, :phone, :logo, :facebook_link, :twitter_link, {category_ids: []})}
	end
end
