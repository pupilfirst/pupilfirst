class WelcomeController < ApplicationController

	def index
		redirect_to controller: :startups if current_user
	end
end
