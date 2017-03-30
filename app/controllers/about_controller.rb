class AboutController < ApplicationController
  rescue_from ActionView::MissingTemplate, with: -> { raise_not_found }

  # GET /about
  def index
    @sitewide_notice = params[:redirect_from] == 'startupvillage.in'
    render layout: 'application_v2'
  end

  # GET /about/slack
  def slack
    render layout: 'application_v2'
  end

  # GET /about/leaderboard
  def leaderboard
    # TODO: correct @live_batches once the test batches are cleaned up.
    @live_batches = Batch.where(batch_number: 3) # Startup.available_batches.live
    @leaderboards = leaderboards_for(@live_batches)
    render layout: 'application_v2'
  end

  # GET /about/press-kit
  def media_kit
    @media_kit_url = 'https://drive.google.com/folderview?id=0B9--SdQuJvHpfjJiam1nTnJCNnVIYkY2NVFXWTQwbXNpWUFoQU1oc1RZSHJraG4yb2Y1cDA&usp=sharing'
    render layout: 'application_v2'
  end

  # GET /about/contact
  def contact
    @sitewide_notice = params[:redirect_from] == 'startupvillage.in'
    render layout: 'application_v2'
  end

  private

  def contact_form_params
    params.require(:contact).permit(:name, :email, :mobile, :company, :query_type, :query)
  end

  def recaptcha_valid?
    return true if Rails.env.test?

    verify_recaptcha(model: @contact_form, message: 'Whoops. Verification of Recaptcha failed. Please try again.')
  end

  def leaderboards_for(batches)
    return nil if batches.blank?

    batches.each_with_object({}) do |batch, leaderboards|
      leaderboards[batch.batch_number] = Startups::PerformanceService.new.leaderboard_with_change_in_rank(batch)
    end
  end
end
