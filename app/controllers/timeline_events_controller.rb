class TimelineEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_founder!, except: %i[review undo_review send_feedback]
  # TODO: Move the above 'authorization' checks to policies.

  # POST /timeline_events
  def create
    timeline_event = authorize(TimelineEvent.new)

    builder_form = TimelineEvents::BuilderForm.new(timeline_event)
    builder_form.founder = current_founder

    if builder_form.validate(timeline_builder_params)
      builder_form.save
      head :ok
    else
      raise "Validation of timeline event creation request failed. Error messages follow: #{builder_form.errors.to_json}"
    end
  end

  # DELETE /timeline_events/:id
  def destroy
    timeline_event = authorize(TimelineEvent.find(params[:id]))

    timeline_event.destroy!
    flash[:success] = 'Timeline event deleted!'

    redirect_back(fallback_location: student_path(current_founder.id))
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
    StartupFeedbackModule::EmailService.new(startup_feedback, founder: timeline_event.founder).send
    render json: { error: nil }, status: :ok
  end

  private

  def timeline_builder_params
    params.require(:timeline_event).permit(
      :target_id, :description, :image, :links, :files_metadata,
      files: (params[:timeline_event][:files]&.keys || [])
    )
  end
end
