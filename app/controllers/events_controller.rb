class EventsController < ApplicationController

  def index
    @events = Event.all
  end

  def new
    @event = Event.new
    @location = Location.where("LOWER(title) like ?", 'startup village%')
    #make location by default should be Startup Village. No other location should be allowed 
  end

  def create
    #mail should be sent once the event is approved
    @event = Event.new(event_params)
    if @event.save
      EventMailer.event_registered_email(@event)
      redirect_to events_path
    else
      redirect_to request.referrer
    end
  end


  private

    def event_params
      params.require(:event).permit(:title, :description, :picture, :start_at, :end_at, :location_id, :category_id, :posters_email, :posters_phone_number)
    end

end
