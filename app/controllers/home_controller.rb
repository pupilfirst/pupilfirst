class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:csp_report]

  def index
    @featured_startups = Startup.where(featured: true)
    @navbar_start_transparent = true
    @skip_container = true
  end

  def faculty
    raise_not_found unless feature_active? :faculty_page

    @skip_container = true
  end

  def about
    raise_not_found unless feature_active? :about_page
  end

  def csp_report
    report = JSON.parse(request.body.read)
    Rails.llog.warn({ event: :csp_report }.merge(report['csp-report'].slice('blocked-uri', 'violated-directive', 'source-file')))
    Rails.llog.debug({ event: :full_csp_report }.merge(report))
    render nothing: true
  end
end
