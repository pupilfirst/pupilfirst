class EventsController < ApplicationController

  def index
  end

  def new
    @event = Event.new
  end

  def create
    binding.pry
  end

end
