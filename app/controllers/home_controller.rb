class HomeController < ApplicationController
  def index
    @featured_startups = Startup.where(featured: true)
    @large_header_class = 'home-index'
    @skip_container = true
  end

  def apply
    batch = params[:batch] || 'default'
    @skip_container = true
    
    render "home/apply/batch-#{batch}"
  end
end
