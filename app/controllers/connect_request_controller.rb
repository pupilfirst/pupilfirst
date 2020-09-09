class ConnectRequestController < ApplicationController
  # Ask to authenticate if no token for join_session. Only faculty is given token.
  before_action :authenticate_and_return, only: :join_session, unless: proc { params[:token].present? }

  # GET /connect_request/:id/feedback/from_team/:token
  def feedback_from_team
    load_comment_form_for_team

    @rating_recorded = true if @connect_request.update(rating_for_faculty: params[:rating])

    render 'comment_form'
  end

  # GET /connect_request/:id/feedback/from_faculty/:token
  def feedback_from_faculty
    load_comment_form_for_faculty

    @rating_recorded = true if @connect_request.update(rating_for_team: params[:rating])

    render 'comment_form'
  end

  # PATCH /connect_request/:id/feedback/comment/:token
  def comment_submit
    if params[:from] == 'faculty'
      load_comment_form_for_faculty
    else
      load_comment_form_for_team
    end
    if @comment_form.validate(params[:connect_requests_comment])
      @comment_form.save
      flash[:success] = 'Thank you! Your comment about the connect session has been saved.'
      redirect_to root_url
    else
      render 'comment_form'
    end
  end

  # GET /connect_request/:id/join_session(/:token)
  def join_session
    @connect_request = ConnectRequest.find(params[:id])

    unless ConnectRequestPolicy.new(pundit_user, @connect_request).join_session?(params[:token])
      raise_not_found
    end
  end

  private

  def load_comment_form_for_team
    founder = Founder.find_by(auth_token: params[:token])
    @connect_request = authorize(founder&.startup&.connect_requests&.find(params[:id]))

    @comment_form = ConnectRequests::CommentForm.new(@connect_request)
    @comment_form.from = :team
  end

  def load_comment_form_for_faculty
    faculty = Faculty.find_by(token: params[:token])
    @connect_request = authorize(faculty&.connect_requests&.find(params[:id]))

    @comment_form = ConnectRequests::CommentForm.new(@connect_request)
    @comment_form.from = :faculty
  end

  def faculty_feedback_params
    params.require(:faculty_feedback).permit(:comment_for_team)
  end

  def authenticate_and_return
    return if current_founder.present?

    session[:referrer] = connect_request_join_session_path(params[:id])
    authenticate_founder!
  end
end
