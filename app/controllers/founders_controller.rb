class FoundersController < ApplicationController
  before_action :authenticate_founder!, except: :founder_profile
  before_action :skip_container, only: %i[founder_profile]

  def founder_profile
    @founder = Founder.friendly.find(params[:slug])
    authorize @founder

    @timeline = @founder.activity_timeline
  end

  # GET /founders/:id/edit
  def edit
    @founder = current_founder.decorate
    authorize @founder.model
  end

  # PATCH /founders/:id
  def update
    @founder = current_founder.decorate
    authorize @founder.model
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
end
