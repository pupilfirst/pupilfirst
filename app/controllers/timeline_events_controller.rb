class TimelineEventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :restrict_to_startup_founders

  # POST /users/:user_id/startup/timeline_events
  def create
    startup = current_user.startup
    timeline_event = startup.timeline_events.new timeline_event_params

    if timeline_event.save
      flash[:success] = 'Your new timeline event has been submitted to the SV team for approval!'
      redirect_to startup
    else
      flash[:error] = 'There seems to be an error in your submission. Please try again!'
      render 'startups/show'
    end
  end

  # DELETE /users/:user_id/startup/timeline_events/:id
  def destroy
    startup = current_user.startup
    timeline_event = startup.timeline_events.find(params[:id])

    if timeline_event.destroy
      flash[:success] = 'Timeline event deleted!'
      redirect_to startup
    else
      flash[:error] = "Something went wrong, and we couldn't delete the timeline event! :("
      render 'startups/show'
    end
  end

  private

  def timeline_event_params
    params.require(:timeline_event).permit(:timeline_event_type_id, :event_on, :description, :image, :link_url, :link_title)
  end

  def restrict_to_startup_founders
    unless current_user.is_founder?
      raise_not_found
    end
  end
end
