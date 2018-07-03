class TimelineEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_founder!, except: %i[review undo_review]
  before_action :require_active_subscription, except: %i[create review undo_review]
  # TODO: Move the above 'authorization' checks to policies.

  # POST /timeline_events
  def create
    timeline_event = TimelineEvent.new
    authorize timeline_event
    builder_form = TimelineEvents::BuilderForm.new(timeline_event)

    if builder_form.validate(timeline_builder_params)
      builder_form.save(current_founder)
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
    # TODO: Handle review
  end

  # POST /timeline_events/:id/undo_review
  def undo_review
    timeline_event = TimelineEvent.find(params[:id])
    authorize timeline_event
    # TODO: Handle undo_review
  end

  private

  def timeline_builder_params
    params.require(:timeline_event).permit(
      :target_id, :timeline_event_type_id, :event_on, :description, :image, :links, :files_metadata, :share_on_facebook,
      files: (params[:timeline_event][:files]&.keys || [])
    )
  end
end
