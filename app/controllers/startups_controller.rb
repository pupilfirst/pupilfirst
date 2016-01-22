class StartupsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :restrict_to_startup_founders, only: [:edit, :update, :add_founder]
  before_filter :restrict_to_startup_admin, only: [:remove_founder]
  before_filter :disallow_unready_startup, only: [:edit, :update]

  after_filter only: [:create] do
    @startup.founders << current_user
    @startup.save
  end

  # GET /startups
  def index
    @batches = Startup.available_batches.order('batch_number DESC')
    @skip_container = true
  end

  def new
    @skip_container = true
    if current_user.phone.blank?
      session[:referer] = new_user_startup_url
      redirect_to phone_user_path
      return
    end

    if current_user.startup.present?
      flash[:alert] = "You've already submitted an application for incubation."
      redirect_to root_url
    end

    @startup = Startup.new
  end

  # POST /startups/team_leader_consent
  def team_leader_consent
    if current_user.startup.present? || !current_user.phone?
      redirect_to new_user_startup_path
    else
      Startup.new_incubation!(current_user)
      redirect_to incubation_path(id: :user_profile)
    end
  end

  def show
    @startup = Startup.friendly.find(params[:id])

    @timeline_event = if params[:event_id]
      @startup.timeline_events.find(params[:event_id])
    else
      @startup.timeline_events.new
    end
  end

  def edit
    @startup = current_user.startup
  end

  def update
    @current_user = current_user
    @startup = @current_user.startup
    @startup.founders.each { |f| f.full_validation = true }
    @startup.validate_web_mandatory_fields = true

    if @startup.update(startup_params)
      flash[:success] = 'Startup details have been updated.'
      redirect_to @startup
    else
      render 'startups/edit'
    end
  end

  # POST /add_founder
  def add_founder
    begin
      current_user.add_as_founder_to_startup!(params[:cofounder][:email])
    rescue Exceptions::UserNotFound
      flash[:error] = "Couldn't find a user with the SV.CO ID you supplied. Please verify founder's registered email address."
    rescue Exceptions::UserAlreadyMemberOfStartup
      flash[:info] = 'The SV.CO ID you supplied is already linked to your startup!'
    rescue Exceptions::UserAlreadyHasStartup
      flash[:notice] = 'The SV.CO ID you supplied is already linked to another startup. Are you sure you have the right e-mail address?'
    else
      flash[:success] = "SV.CO ID #{params[:email]} has been linked to your startup as founder"
    end

    redirect_to edit_user_startup_path
  end

  # PATCH /remove_founder
  def remove_founder
    founder_to_remove = current_user.startup.founders.find_by id: params[:founder_id]
    if founder_to_remove.present?
      founder_to_remove.update(is_founder: false, startup_id: nil)
      flash.now[:success] = "The founder was successfully removed from your startup!"
    else
      flash.now[:error] = "There was an error in removing the founder!"
    end
    redirect_to :back
  end

  # DELETE /users/:id/startup/destroy
  def destroy
    @startup = current_user.startup

    if current_user.startup_admin
      if current_user.startup_admin && current_user.valid_password?(startup_destroy_params[:password])
        @startup.destroy!
        flash[:success] = 'Your startup profile and all associated data has been deleted.'
        redirect_to root_url
        return
      else
        flash.now[:error] = 'Authentication failed!'
      end
    else
      flash.now[:error] = 'You are not allowed to perform this action!'
    end

    render 'edit'
  end

  private

  def startup_params
    params.require(:startup).permit(
      :name, :legal_registered_name, :address, :pitch, :website, :email, :logo, :remote_logo_url, :facebook_link,
      :twitter_link, :product_name, :product_description,
      { startup_category_ids: [] }, { founders_attributes: [:id] },
      :registration_type, :revenue_generated, :presentation_link, :product_video, :wireframe_link, :prototype_link, :team_size, :women_employees, :slug
    )
  end

  def startup_destroy_params
    params.require(:startup).permit(:password)
  end

  def restrict_to_startup_founders
    return if current_user.is_founder?
    raise_not_found
  end

  def restrict_to_startup_admin
    return if current_user.startup_admin?
    raise_not_found
  end

  # A startup that is in unready state shouldn't be allowed to edit its details.
  #
  # @see https://trello.com/c/y4ReClzt
  def disallow_unready_startup
    return unless current_user.startup.unready?
    flash[:error] = "You haven't completed the incubation process yet. Please complete it before attempting to edit your startup's profile."
    redirect_to current_user
  end
end
