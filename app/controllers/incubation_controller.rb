class IncubationController < ApplicationController
  include Wicked::Wizard

  steps 'user_profile', 'startup_profile', 'launch'

  def show
    @startup = current_user.startup
    @user = current_user
    render_wizard
  end

  def update
    @startup = current_user.startup
    @user = current_user

    # Save update_from so as to use for conditional validations during params update.
    @startup.updated_from = step
    @startup.save! validate: false

    # Update startup (and user) with received params.
    if @startup.update(incubation_startup_params)
      # When updating from startup_profile step, also set approval status to pending.
      if step == 'startup_profile'
        @startup.update!(approval_status: Startup::APPROVAL_STATUS_PENDING)
      end
    end

    render_wizard @startup
  end

  # Wicked uses this method to find out where to redirect to once the wizard finishes.
  def finish_wizard_path
    current_user.startup
  end

  # Attempt to a co-founder, and return to the launch page.
  def add_cofounder
    User.add_cofounder(params[:email],current_user.startup.id)
    UserMailer.cofounder_request(params[:email], current_user).deliver_later
    flash[:notice] = "An email has been sent to #{params[:email]} inviting him/her to join as a cofounder"

    redirect_to incubation_path(:launch)
  end

  private

  def incubation_startup_params
    params.require(:startup).permit(:name, :registration_type, :pitch, :about,
     :cool_fact, :incubation_location, :website, :revenue_generated,
      :presentation_link, :team_size, :women_employees, :product_name,
      :product_description, :product_progress, :updated_from,
       admin_attributes: [:id, :gender, :born_on, :communication_address,
        :district, :state, :pin, :linkedin_url, :twitter_url])
  end

  # def incubation_user_params
  #   params.require()
  # end
end
