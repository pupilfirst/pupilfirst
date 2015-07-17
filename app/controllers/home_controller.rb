class HomeController < ApplicationController
  def index
    @featured_startups = Startup.where(featured: true)
    render layout: 'homepage'
  end

  def faculty
    @skip_container = true
    render layout: 'application'
  end
end
