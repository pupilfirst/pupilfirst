class CoachDashboardController < ApplicationController
  before_action :authenticate_user!, :course

  def show
    @skip_container = true
  end

  def timeline_events
    service = CoachDashboard::TimelineEventsDataService.new(
      current_coach,
      @course,
      params[:reviewStatus].to_sym,
      params[:excludedIds],
      params[:limit]
    )

    render(
      json: {
        timelineEvents: service.timeline_events,
        moreSubmissionsAfter: service.earliest_submission_date,
        error: nil
      }
    )
  end

  private

  def course
    @course = authorize(Course.find(params[:course_id]), policy_class: CoachDashboardPolicy)
  end
end
