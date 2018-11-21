class TimelineEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_founder!, except: %i[review undo_review send_feedback]
  before_action :require_active_subscription, except: %i[create review undo_review send_feedback]
  # TODO: Move the above 'authorization' checks to policies.

  # POST /timeline_events
  def create
    timeline_event = authorize(TimelineEvent.new)
    builder_form = TimelineEvents::BuilderForm.new(timeline_event)
    builder_form.founder = current_founder

    if builder_form.validate(timeline_builder_params)
      builder_form.save
      flash.now[:success] = current_founder.level_zero? ? 'Your submission will be reviewed soon.' : 'Your timeline event will be reviewed soon!'
      head :ok
    else
      raise "Validation of timeline event creation request failed. Error messages follow: #{builder_form.errors.to_json}"
    end
  end

  # DELETE /timeline_events/:id
  def destroy
    timeline_event = TimelineEvent.find(params[:id])
    authorize timeline_event

    timeline_event.destroy!
    flash[:success] = 'Timeline event deleted!'
    redirect_to current_founder.startup
  end

  # POST /timeline_events/:id/review
  def review
    timeline_event = TimelineEvent.find(params[:id])
    authorize timeline_event

    if !timeline_event.reviewed?
      begin
        TimelineEvents::VerificationService.new(timeline_event).update_status(grade: params[:grade])
        render json: { error: nil }, status: :ok
      rescue TimelineEvents::ReviewInterfaceException => e
        render json: { error: e.message, timelineEvent: nil }.to_json, status: :unprocessable_entity
      end
    else
      # someone else already reviewed this event! Ask javascript to reload page.
      render json: { error: 'Event no longer pending review! Refreshing your dashboard.', timelineEvent: nil }.to_json, status: :unprocessable_entity
    end
  end

  # POST /timeline_events/:id/undo_review
  def undo_review
    timeline_event = TimelineEvent.find(params[:id])
    authorize timeline_event

    unless timeline_event.reviewed?
      render json: { error: 'Event is pending review! Cannot undo.' }.to_json, status: :unprocessable_entity
      return
    end

    TimelineEvents::UndoVerificationService.new(timeline_event).execute
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
      :target_id, :event_on, :description, :image, :links, :files_metadata, :share_on_facebook,
      files: (params[:timeline_event][:files]&.keys || [])
    )
  end
end
