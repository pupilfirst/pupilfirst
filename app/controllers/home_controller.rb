class HomeController < ApplicationController
  def index
    @featured_startups = Startup.where(featured: true)
    render layout: 'homepage'
  end

  def faculty
    raise_not_found unless DbConfig.feature_active? :faculty_page, current_user

    @skip_container = true
    render layout: 'application'
  end

  def foundation
    raise_not_found unless DbConfig.feature_active? :foundation_page, current_user

    render layout: 'application'
  end
end
