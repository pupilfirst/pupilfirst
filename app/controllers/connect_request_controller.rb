class ConnectRequestController < ApplicationController
  # Ask to authenticate if no token for join_session. Only faculty is given token.
  before_action :authenticate_and_return, only: :join_session, unless: proc { params[:token].present? }

  # GET /connect_request/:id/feedback/from_team/:token
  def feedback_from_team
    founder = Founder.find_by(auth_token: params[:token])
    connect_request = founder&.startup&.connect_requests&.find(params[:id])
    authorize connect_request

    if connect_request.update(rating_for_faculty: params[:rating])
      flash[:success] = 'Thank you! Your rating for the office hour has been saved.'
    else
      flash[:error] = "We're sorry, but something went wrong when we tried to save that rating."
    end

    redirect_to root_url
  end

  # GET /connect_request/:id/feedback/from_faculty/:token
  def feedback_from_faculty
    faculty = Faculty.find_by(token: params[:token])
    connect_request = faculty&.connect_requests&.find(params[:id])
    authorize connect_request

    @rating_recorded = true if connect_request.update(rating_for_team: params[:rating])
    @karma_points_added = true if connect_request.assign_karma_points(params[:rating])
  end

  # GET /connect_request/:id/join_session(/:token)
  def join_session
    @connect_request = ConnectRequest.find(params[:id])

    unless ConnectRequestPolicy.new(current_user, @connect_request).join_session?(params[:token])
      raise_not_found
    end
  end

  private

  def authenticate_and_return
    return if current_founder.present?

    session[:referer] = connect_request_join_session_path(params[:id])
    authenticate_founder!
  end
end
