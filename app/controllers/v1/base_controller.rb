class V1::BaseController < ApplicationController
	respond_to :json
	skip_before_filter :verify_authenticity_token
	# before_filter :require_token

  def current_user
    return @current_user if @current_user
    @current_user = User.find_by_auth_token(auth_token) if auth_token
    @current_user
  end


  def auth_token
    params[:auth_token] || request.headers['HTTP_API_TOKEN']
  end

private

	def require_token
		raise "varify token requirment are satisfied"
	  unless valid_token?
	    logger.error "Request halted as no auth_token #{params}"
	    # raise "auth_token required given: #{auth_token}"
	  end
	end

	def valid_token?
	  !! current_user
	end
end
