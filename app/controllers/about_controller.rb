class AboutController < ApplicationController
  rescue_from ActionView::MissingTemplate, with: -> { raise_not_found }

  # GET /about
  def index
  end

  # GET /about/transparency
  def transparency
  end

  # GET /about/slack
  def slack
  end

  # GET /about/leaderboard
  def leaderboard
  end

  def press_kit
    @press_kit_url = "https://drive.google.com/folderview?id=0B9--SdQuJvHpfjJiam1nTnJCNnVIYkY2NVFXWTQwbXNpWUFoQU1oc1RZSHJraG4yb2Y1cDA&usp=sharing"
  end
end
