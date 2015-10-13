class HomeController < ApplicationController
  def index
    @featured_startups = Startup.where(featured: true)
    @large_header_class = 'home-index'
    @skip_container = true
  end
end
