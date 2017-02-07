class FoundersController < ApplicationController
  before_action :authenticate_founder!, except: :founder_profile
  before_action :skip_container, only: [:founder_profile, :dashboard]

  def founder_profile
    @founder = Founder.friendly.find(params[:slug])
    @timeline = @founder.activity_timeline
  end

  # GET /founders/:id/edit
  def edit
    @founder = current_founder.decorate
  end

  # PATCH /founders/:id
  def update
    @founder = current_founder.decorate
    form = @founder.form

    if form.validate(params[:founders_edit])
      form.save!
      flash[:success] = 'Your profile has been updated.'
      redirect_to founder_profile_path(slug: @founder.slug)
    else
      render 'edit'
    end
  end

  # GET /founder/dashboard
  def dashboard
    @header_non_floating = true

    @startup = current_founder.startup&.decorate
    @batch = @startup&.batch&.decorate

    # founders without proper startups will not have dashboards
    raise_not_found unless @startup.present? && @batch.present?

    @tour = take_on_tour?

    if filtered_targets_required?
      @filtered_targets = Founders::TargetsFilterService.new(current_founder).filter(params[:filter])
    else
      # Eager-load everything required for the dashboard. Order and decorate them too!
      @program_weeks = @batch.program_weeks.includes(:batch, target_groups: { targets: :assigner }).order(:number, 'target_groups.sort_index', 'targets.sort_index').decorate
    end

    render layout: 'application_v2'
  end

  private

  def skip_container
    @skip_container = true
  end

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

  def founder_params
    params.require(:founders_edit).permit(
      :name, :avatar, :slack_username, :skype_id, :identification_proof, :phone,
      :college_identification, :course, :semester, :year_of_graduation, :about, :twitter_url, :linkedin_url,
      :personal_website_url, :blog_url, :angel_co_url, :github_url, :behance_url, :college_id,
      :roll_number, :born_on, :communication_address, roles: []
    )
  end

  def take_on_tour?
    current_founder.present? && current_founder.startup == @startup.model && (current_founder.tour_dashboard? || params[:tour].present?)
  end

  def filtered_targets_required?
    return false unless params[:filter].present?
    return false if params[:filter] == Founders::TargetsFilterService::ALL_TARGETS
    return true if Founders::TargetsFilterService.filters_for_dashboard.include?(params[:filter])
    false
  end
end
