class ConnectRequestController < ApplicationController
  # GET /connect_request/:id/feedback/from_team/:token
  def feedback_from_team
    admin = Founder.find_by(auth_token: params[:token])

    raise_not_found if admin.blank?

    connect_request = admin.startup.connect_requests.find(params[:id])

    if connect_request.update(rating_of_faculty: params[:rating])
      flash[:success] = 'Thank you! Your rating of the connect session has been saved.'
    else
      flash[:error] = "We're sorry, but something went wrong when we tried to save that rating."
    end

    redirect_to root_url
  end

  # GET /connect_request/:id/feedback/from_faculty/:token
  def feedback_from_faculty
    faculty = Faculty.find_by(token: params[:token])

    raise_not_found if faculty.blank?

    connect_request = faculty.connect_requests.find(params[:id])

    if connect_request.update(rating_of_team: params[:rating])
      flash[:success] = if connect_request.assign_karma_points(params[:rating])
        'Thank you! Your rating of the connect session has been saved, and karma points have been assigned.'
      else
        'Thank you! Your rating of the connect session has been saved.'
      end
    else
      flash[:error] = "We're sorry, but something went wrong when we tried to save that rating."
    end

    redirect_to root_url
  end

  # GET /connect_request/:id/join_session(/:token)
  def join_session
    @connect_request = retrieve_connect_request
    raise_not_found unless @connect_request.present?
  end

  private

  def retrieve_connect_request
    params[:token].present? ? retrieve_for_faculty : retrieve_for_founder
  end

  def retrieve_for_faculty
    Faculty.find_by(token: params[:token])&.connect_requests&.confirmed&.find_by(id: params[:id])
  end

  def retrieve_for_founder
    current_founder&.startup&.connect_requests&.confirmed&.find_by(id: params[:id])
  end
end
