class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	before_filter :configure_permitted_parameters, if: :devise_controller?

	def raise_not_found
	  raise ActionController::RoutingError.new('Not Found')
	end

	protected

	def configure_permitted_parameters
	  devise_parameter_sanitizer.for(:accept_invitation).concat [:avatar, :twitter_url, :linkedin_url, :username]
	end

end
