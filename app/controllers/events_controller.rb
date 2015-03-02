class EventsController < ApplicationController

  def index
    @events = Event.approved_events.where('start_at <= ? and start_at > ?', 30.days.from_now, Date.today)
    @event = Event.first
    EventMailer.event_registered_email(@event).deliver_now
  end

  def new
    @event = Event.new
    event_categories
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      EventMailer.event_registered_email(@event).deliver_now
      redirect_to events_path, :notice => "Your Event has been submitted for approval, please check your mail for further details"
    else
      event_categories
      render :new
    end
  end

  def show
    @event = Event.find(params[:id])
  end


  private

  def event_params
    params.require(:event).permit(:title, :description, :picture, :start_at, :end_at, :location, :category_id, :posters_email, :posters_name, :posters_phone_number)
  end

  def event_categories
    @event_categories = Category.event_category.all
  end

end
