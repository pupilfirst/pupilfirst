class OnboardingController < ApplicationController

  include Wicked::Wizard
  steps :user_profile, :startup_profile, :product_description

  def show
    @startup = current_user.startup
    render_wizard
  end

  def update
    @startup = current_user.startup
    # @startup.attributes = params[:startup]
    render_wizard @startup
  end

end
