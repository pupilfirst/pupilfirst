class TimelineEventsController < ApplicationController
  before_action :authenticate_user!

  # GET /submissions/:id
  def show
    submission = authorize(TimelineEvent.find(params[:id]))
    @course = submission.target.course
    render 'courses/review', layout: 'student_course'
  end
end
