class V1::BaseController < ApplicationController
	respond_to :json
	skip_before_filter :verify_authenticity_token
	before_filter :require_token

  def current_user
    return @current_user if @current_user
    @current_user = User.find_by_auth_token(auth_token) if auth_token
    @current_user
  end

  rescue_from StandardError do |exception|
  	status = case exception
	  	when ActiveRecord::RecordInvalid then 400
	  	when ActiveRecord::RecordNotFound then 404
	  	else
	  		logger.fatal "UNIDENTIFIED ERROR OCCURED IN API :: #{exception.class} #{exception.message}, #{exception.backtrace}"
	  		raise exception
	  	end
    render :json => {error: exception.message}, :status => 500
    true
  end

  def auth_token
    params[:auth_token] || request.headers['HTTP_AUTH_TOKEN']
  end

private

	def require_token
	  unless valid_token?
	    logger.error "Request halted as no auth_token #{params}"
	    raise "auth_token required given: #{auth_token}"
	  end
	end

	def valid_token?
	  !! current_user
	end
end
