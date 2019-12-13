class FoundersController < ApplicationController
  before_action :skip_container, only: %i[show paged_events timeline_event_show]

  # GET /students/:id
  def show
    @founder = authorize(Founder.find(params[:id]))
    # Show site wide notice to exited founders
    @sitewide_notice = @founder.dropped_out? if @founder.user == current_user
    @timeline_events = Kaminari.paginate_array(events_for_display).page(params[:page]).per(20)
  end

  # GET /students/:id/events/:page
  def paged_events
    # Reuse the founder_profile action, because that's what this page also shows.
    show
    render layout: false
  end

  # GET /students/:id/:event_title/:event_id
  def timeline_event_show
    # Reuse the startup action, because that's what this page also shows.
    show
    @timeline_event_for_og = @founder.timeline_events.find(params[:event_id])

    unless TimelineEventPolicy.new(pundit_user, @timeline_event_for_og).show?
      raise_not_found
    end

    render 'show'
  end

  # GET /students/:id/report
  def report
    student = authorize(Founder.find(params[:id]))
    @course = student.course
    render 'courses/students', layout: 'student_course'
  end

  private

  def skip_container
    @skip_container = true
  end

  def events_for_display
    # Only display verified of needs-improvement events if 'current_user' is not the user
    if current_user != @founder.user
      @founder.timeline_events.passed.includes(:target, :timeline_event_files).order(:created_at, :updated_at).reverse_order
    else
      @founder.timeline_events.includes(:target, :timeline_event_files).order(:created_at, :updated_at).reverse_order
    end
  end
end
