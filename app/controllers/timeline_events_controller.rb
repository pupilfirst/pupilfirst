class TimelineEventsController < ApplicationController
  before_action :authenticate_user!

  # GET /submissions/:id/review
  def review
    submission = authorize(TimelineEvent.find(params[:id]))
    @course = submission.target.course
    render html: '', layout: 'app_router'
  end

  # GET /submissions/:id
  def show
    @submission = authorize(TimelineEvent.find(params[:id]))
    render layout: 'student'
  end
end
