class TimelineEventsController < ApplicationController
  before_action :authenticate_founder!, except: [:activity]
  before_action :restrict_to_startup_founders, except: [:activity]

  # POST /founder/startup/timeline_events
  def create
    timeline_event = TimelineEvent.new
    @timeline_builder_form = TimelineBuilderForm.new(timeline_event)

    if @timeline_builder_form.validate(timeline_builder_params)
      @timeline_builder_form.save(current_founder)
      flash.now[:success] = 'Your timeline event will be reviewed soon!'
      head :ok
    else
      raise "Validation of timeline event creation request failed. Error messages follow: #{@timeline_builder_form.errors.to_json}"
    end
  end

  # DELETE /founder/startup/timeline_events/:id
  def destroy
    @startup = current_founder.startup
    @timeline_event = @startup.timeline_events.find(params[:id])

    # Do not allow destruction of verified / needs improvement timeline events.
    if @timeline_event.founder_can_modify? && @timeline_event.destroy
      flash[:success] = 'Timeline event deleted!'
    else
      flash[:error] = "Something went wrong, and we couldn't delete the timeline event! :("
    end

    redirect_to @startup
  end

  # POST /founder/startup/timeline_events/:id
  def update
    @startup = current_founder.startup
    @timeline_event = @startup.timeline_events.find(params[:id])

    merged_params = timeline_event_params.merge(
      links: JSON.parse(timeline_event_params[:links]),
      files: params.dig(:timeline_event, :files),
      files_metadata: JSON.parse(timeline_event_params[:files_metadata])
    )

    if @timeline_event.founder_can_modify? && @timeline_event.update_and_require_reverification(merged_params)
      flash.now[:success] = 'Timeline event updated!'
      head :ok
    else
      flash.now[:error] = 'There seems to be an error in your submission. Please try again!'
      head :unprocessable_entity
    end
  end

  def activity
    @batches = Startup.available_batches.order('batch_number DESC')
    @skip_container = true
  end

  private

  def timeline_builder_params
    params.require(:timeline_event).permit(
      :target_id, :timeline_event_type_id, :event_on, :description, :image, :links, :files_metadata, :share_on_facebook,
      files: (params[:timeline_event][:files]&.keys || [])
    )
  end

  def timeline_event_params
    params.require(:timeline_event).permit(
      :timeline_event_type_id, :event_on, :description, :image, :links, :files_metadata
    )
  end

  def restrict_to_startup_founders
    return if current_founder
    raise_not_found
  end
end
