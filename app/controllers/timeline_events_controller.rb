class TimelineEventsController < ApplicationController
  before_action :authenticate_user!

  # GET /submissions/:id
  def show
    submission = authorize(TimelineEvent.find(params[:id]))
    @course = submission.target.course
    render 'courses/review', layout: 'student_course'
  end

  # POST /timeline_events/:id/review
  def review
    timeline_event = authorize(TimelineEvent.find(params[:id]))

    begin
      # TODO: Probably replace this with a better encoder on the front-end.
      grades = params[:evaluation].each_with_object({}) do |entry, result|
        result[entry['criterionId'].to_i] = entry['grade'].to_i
      end

      TimelineEvents::GradingService.new(timeline_event).grade(current_coach, grades)
      render json: { error: nil }, status: :ok
    rescue TimelineEvents::GradingService::AlreadyReviewedException
      render json: { error: 'Event no longer pending review! Try refreshing your dashboard.', timelineEvent: nil }.to_json, status: :unprocessable_entity
    end
  end

  # POST /timeline_events/:id/undo_review
  def undo_review
    timeline_event = authorize(TimelineEvent.find(params[:id]))

    begin
      TimelineEvents::UndoGradingService.new(timeline_event).execute
    rescue TimelineEvents::UndoGradingService::ReviewPendingException
      render json: { error: 'Event is pending review! Cannot undo.' }.to_json, status: :unprocessable_entity
      return
    end

    render json: { error: nil }, status: :ok
  end

  # POST /timeline_events/:id/send_feedback
  def send_feedback
    timeline_event = TimelineEvent.find(params[:id])
    authorize timeline_event

    # TODO: Clean up startup-feedback related services and move the following there
    startup_feedback = StartupFeedback.create!(
      feedback: params[:feedback],
      startup: timeline_event.startup,
      faculty: current_coach,
      timeline_event: timeline_event
    )
    StartupFeedbackModule::EmailService.new(startup_feedback).send
    render json: { error: nil }, status: :ok
  end
end
