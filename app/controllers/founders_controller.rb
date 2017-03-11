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
end
