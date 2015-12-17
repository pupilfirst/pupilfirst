class HomeController < ApplicationController
  def index
    @featured_startups = Startup.where(featured: true)
    @large_header_class = 'home-index'
    @skip_container = true
  end


  def apply
    @skip_container = true
  end

  def cached_404
    render 'errors/not_found', layout: 'error'
  end
end
