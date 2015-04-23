class OnboardingController < ApplicationController

  include Wicked::Wizard
  steps :user_profile, :startup_profile, :product_description

  def show
    @startup = current_user.startup
    @user = current_user
    render_wizard
  end

  def update
    # binding.pry
    @startup = current_user.startup
    @user = current_user
    # @startup.attributes = onboarding_startup_params
    @startup.update(onboarding_startup_params)
    # current_user.attributes = onboarding_user_params
    render_wizard @startup
  end

  private

  def onboarding_startup_params
    params.require(:startup).permit(:name, :pitch, :about, admin_attributes: [:id, :gender])
  end
  # def onboarding_user_params
  #   params.require()
  # end

end
