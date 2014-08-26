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
    status = 500

    status = case exception
      when ActionController::ParameterMissing
        400
      when ActiveRecord::RecordInvalid then
        400
      when Exceptions::ApiStandardError then
        exception.status
      when ActiveRecord::RecordNotFound then
        404
      when ArgumentError then
        400
      else
        logger.fatal "UNIDENTIFIED ERROR OCCURRED IN API :: #{exception.class} #{exception.message}, #{exception.backtrace}"
        raise exception
    end

    render :json => { error: exception.message, code: exception.class.name.demodulize }, status: status
    true
  end

  def auth_token
    params[:auth_token] || request.headers['HTTP_AUTH_TOKEN']
  end

  private

  def require_token
    unless valid_token?
      logger.error "Request halted since valid auth_token was missing: #{params}"
      raise Exceptions::AuthTokenInvalid, "auth_token required. Given: '#{auth_token}'"
    end
  end

  def require_self
    if params[:id] != 'self' || params[:id] == current_user.id
      raise Exceptions::RestrictedToSelf, 'You may not perform this action for another user. Use self.'
    end
  end

  def valid_token?
    !!current_user
  end
end
