class WelcomeController < ApplicationController
  layout 'home'

	def index
		if current_user and current_user.startup.present?
			redirect_to current_user.startup
		elsif current_user
			redirect_to controller: :startups
		end
	end
end
