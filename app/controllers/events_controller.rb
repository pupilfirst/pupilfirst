class EventsController < ApplicationController

  def index
    @events = Event.all
  end

  def new
    @event = Event.new
    event_locations
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      EventMailer.event_registered_email(@event)
      redirect_to events_path
    else
      event_locations
      render :new
    end
  end


  private

    def event_params
      params.require(:event).permit(:title, :description, :picture, :start_at, :end_at, :location_id, :category_id, :posters_email, :posters_phone_number)
    end

    def event_locations
      @location = Location.where("LOWER(title) like ?", 'startup village%')
    end

end
