class IncubationController < ApplicationController
  before_filter :authenticate_user!

  include Wicked::Wizard

  steps 'user_profile', 'startup_profile', 'launch'

  def show
    return if prevent_repeat!

    @startup = current_user.startup
    @user = current_user
    render_wizard
  end

  def update
    return if prevent_repeat!

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
    begin
      User.add_as_founder_to_startup!(params[:cofounder][:email], current_user.startup)
    rescue Exceptions::UserNotFound
      flash[:error] = "Couldn't find a user with the SV ID you supplied. Please verify founder's registered email address."
    rescue Exceptions::UserAlreadyMemberOfStartup
      flash[:info] = 'The SV ID you supplied is already linked to your startup!'
    rescue Exceptions:: UserAlreadyHasStartup
      flash[:notice] = 'The SV ID you supplied is already linked to another startup. Are you sure you have the right e-mail address?'
    else
      UserMailer.cofounder_addition(params[:email], current_user).deliver_later
      flash[:success] = "SV ID #{params[:email]} has been linked to your startup as founder"
    end

    redirect_to incubation_path(:launch)
  end

  private

  def incubation_startup_params
    params.require(:startup).permit(:name, :registration_type, :about, :incubation_location, :website,
      :presentation_link, :team_size, :women_employees, :updated_from, admin_attributes: [
        :id, :gender, :born_on, :communication_address, :district, :state, :pin, :linkedin_url, :twitter_url
      ]
    )
  end

  def prevent_repeat!
    unless current_user.startup.unready?
      if step != 'launch'
        flash[:info] = "You've already completed the incubation process. You don't need to repeat that!"
        redirect_to root_url and return true
      end
    end

    false
  end
end
