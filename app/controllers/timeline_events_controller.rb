class TimelineEventsController < ApplicationController
  before_action :authenticate_founder!, except: [:activity]
  before_action :require_active_subscription

  # POST /timeline_events
  def create
    timeline_event = TimelineEvent.new
    authorize timeline_event
    builder_form = TimelineEvents::BuilderForm.new(timeline_event)

    if builder_form.validate(timeline_builder_params)
      builder_form.save(current_founder)
      flash.now[:success] = 'Your timeline event will be reviewed soon!'
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

  private

  def timeline_builder_params
    params.require(:timeline_event).permit(
      :target_id, :timeline_event_type_id, :event_on, :description, :image, :links, :files_metadata, :share_on_facebook,
      files: (params[:timeline_event][:files]&.keys || [])
    )
  end
end
