class OnboardingController < ApplicationController

  include Wicked::Wizard
  steps :user_profile, :startup_profile, :product_description, :finish

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

  def finish_wizard_path
    current_user.startup
  end

  private

  def onboarding_startup_params
    params.require(:startup).permit(:name, :registration_type, :pitch, :about,
     :cool_fact, :incubation_location, :website, :revenue_generated,
      :presentation_link, :team_size, :women_employees, :product_name,
      :product_description, :product_progress,
       admin_attributes: [:id, :gender, :born_on, :communication_address,
        :district, :state, :pin, :linkedin_url, :twitter_url])
  end
  # def onboarding_user_params
  #   params.require()
  # end

end
