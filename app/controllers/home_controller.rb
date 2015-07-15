class HomeController < ApplicationController
  layout 'homepage'

  def index
    @featured_startups = Startup.where(featured: true)
  end
end
