class HomeController < ApplicationController
  def index
    @large_header_class = 'home-index'
    @skip_container = true
    @sitewide_notice = true if %w(startupvillage.in registration).include?(params[:redirect_from])
  end

  def apply
    batch = params[:batch] || 'default'
    @skip_container = true

    raise_not_found unless %w(default 3).include?(batch)

    render "home/apply/batch-#{batch}"
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
    @changelog = File.read(File.absolute_path(Rails.root.join('CHANGELOG.md')))
    render layout: 'application_v2'
  end

  def styleguide
    render layout: 'application_v2'
  end
end
