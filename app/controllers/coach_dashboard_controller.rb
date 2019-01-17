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
    timeline_events = service.timeline_events
    more_to_load = service.more_to_load?
    render json: { timelineEvents: timeline_events, moreToLoad: more_to_load, error: nil }
  end

  private

  def course
    @course = authorize(Course.find(params[:course_id]), policy_class: CoachDashboardPolicy)
  end
end
