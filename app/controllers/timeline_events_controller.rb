class TimelineEventsController < ApplicationController
  before_filter :authenticate_founder!
  before_filter :restrict_to_startup_founders

  # POST /founder/startup/timeline_events
  def create
    @startup = current_founder.startup
    @timeline_event = @startup.timeline_events.new timeline_event_params.merge(
      links: JSON.parse(timeline_event_params[:links]),
      founder: current_founder,
      files: params.dig(:timeline_event, :files),
      files_metadata: JSON.parse(timeline_event_params[:files_metadata])
    )

    if @timeline_event.save
      flash[:success] = 'Your new timeline event has been submitted to the SV.CO team for approval!'
      redirect_to @startup
    else
      flash[:error] = 'There seems to be an error in your submission. Please try again!'
      render 'startups/show'
    end
  end

  # DELETE /founder/startup/timeline_events/:id
  def destroy
    @startup = current_founder.startup
    @timeline_event = @startup.timeline_events.find(params[:id])

    if @timeline_event.destroy
      flash[:success] = 'Timeline event deleted!'
      redirect_to @startup
    else
      flash[:error] = "Something went wrong, and we couldn't delete the timeline event! :("
      render 'startups/show'
    end
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

    if @timeline_event.update_and_require_reverification(merged_params)
      flash[:success] = 'Timeline event updated!'
      redirect_to @startup
    else
      flash[:error] = "Something went wrong, and we couldn't update the timeline event! :("
      render 'startups/show'
    end
  end

  def timeline
    @batches = Startup.available_batches.order('batch_number DESC')
    @skip_container = true
  end

  private

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
