class HomeController < ApplicationController
  def index
    @large_header_class = 'home-index'
    @skip_container = true
    @sitewide_notice = true if %w(startupvillage.in registration).include?(params[:redirect_from])
  end

  def transparency
    @skip_container = true
  end

  # used by the 'shortener' gem's config
  def not_found
    raise_not_found
  end

  # GET /changelog
  def changelog
    @skip_container = true
    @changelog = File.read(File.absolute_path(Rails.root.join('CHANGELOG.md')))
    render layout: 'application_v2'
  end

  # GET /tour
  def tour
    @skip_container = true
    render layout: 'application_v2'
  end
end
