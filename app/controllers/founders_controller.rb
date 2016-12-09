class FoundersController < ApplicationController
  before_action :authenticate_founder!, except: :founder_profile

  def founder_profile
    @founder = Founder.friendly.find(params[:slug])
    @timeline = @founder.activity_timeline
    @skip_container = true
  end

  # GET /founders/:id/edit
  def edit
    @founder = current_founder.decorate
  end

  # PATCH /founders/:id
  def update
    @founder = current_founder

    # Remove 'other' college ID if selected by founder.
    params[:founder].delete(:college_id) if params.dig(:founder, :college_id) == 'other'

    if @founder.update_attributes(founder_params)
      flash[:notice] = 'Profile updated'
      redirect_to founder_profile_path(slug: @founder.slug)
    else
      @founder = @founder.decorate
      render 'edit'
    end
  end

  # GET /founder/dashboard
  def dashboard
    @header_non_floating = true
    @skip_container = true

    @startup = current_founder.startup
    # eager-load everything required for the dashboard. Order and decorate them too!
    @program_weeks = @startup.batch.program_weeks.includes(target_groups: { targets: :assigner }).order(:number, 'target_groups.sort_index', 'targets.days_to_complete').decorate

    render layout: 'application_v2'
  end

  private

  # If founder's startup has already been created (by team lead), take him there. Otherwise, take him to consent screen.
  def create_startup_or_timeline_path
    if current_founder.startup.present?
      startup_path(current_founder.startup)
    elsif current_founder.startup_admin?
      new_founder_startup_path
    else
      root_path(redirect_from: 'registration')
    end
  end

  def founder_password_change_params
    params.require(:founder).permit(:current_password, :password, :password_confirmation)
  end

  def founder_params
    params.require(:founder).permit(
      :name, :avatar, :slack_username, :skype_id, :identification_proof, :phone,
      :college_identification, :course, :semester, :year_of_graduation, :about, :twitter_url, :linkedin_url,
      :personal_website_url, :blog_url, :facebook_url, :angel_co_url, :github_url, :behance_url, :college_id,
      :roll_number, :born_on, :communication_address, roles: []
    )
  end
end
