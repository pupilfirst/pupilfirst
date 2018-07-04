class AboutController < ApplicationController
  rescue_from ActionView::MissingTemplate, with: -> { raise_not_found }

  # GET /about
  def index
    @sitewide_notice = params[:redirect_from] == 'startupvillage.in'
  end

  # GET /about/slack
  def slack
    # noop
  end

  # GET /about/leaderboard
  def leaderboard
    authorize :about
    @levels = Level.where.not(number: 0).order(number: :desc) # All levels except admissions
    @leaderboards = leaderboards_for(@levels)
  end

  # GET /about/press-kit
  def media_kit
    @media_kit_url = 'https://drive.google.com/folderview?id=0B9--SdQuJvHpfjJiam1nTnJCNnVIYkY2NVFXWTQwbXNpWUFoQU1oc1RZSHJraG4yb2Y1cDA&usp=sharing'
  end

  # GET /about/contact
  def contact
    @sitewide_notice = params[:redirect_from] == 'startupvillage.in'
  end

  private

  def leaderboards_for(levels)
    return nil if levels.blank?

    levels.each_with_object({}) do |level, leaderboards|
      leaderboards[level.number] = Startups::LeaderboardService.new(level).leaderboard_with_change_in_rank
    end
  end
end
