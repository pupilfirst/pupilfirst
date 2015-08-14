class StartupsController < InheritedResources::Base
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :restrict_to_startup_founders, only: [:edit, :update, :add_founder, :add_timeline_event]
  before_filter :disallow_unready_startup, only: [:edit, :update]
  after_filter only: [:create] do
    @startup.founders << current_user
    @startup.save
  end

  def new
    unless current_user.phone_verified?
      session[:referer] = new_user_startup_url(current_user)
      redirect_to phone_user_path(current_user) and return
    end

    if current_user.startup.present?
      if current_user.startup.unready?
        redirect_to incubation_path(id: :user_profile) and return
      else
        flash[:alert] = "You've already submitted an application for incubation."
        redirect_to root_url and return
      end
    else
      Startup.new_incubation!(current_user)
      redirect_to incubation_path(id: :user_profile)
    end
  end

  def index
    @navbar_start_transparent = true
    @skip_container = true
  end

  def show
    @navbar_start_transparent = true
    @skip_container = true

    @startup = Startup.friendly.find(params[:id])
    @timeline_event = @startup.timeline_events.new
    if current_user && @startup == current_user.startup
      @events = @startup.timeline_events.order(:event_on, :updated_at).reverse_order
    else
      @events = @startup.timeline_events.verified.order(:event_on, :updated_at).reverse_order
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
      flash[:error] = "Couldn't find a user with the SV ID you supplied. Please verify founder's registered email address."
    rescue Exceptions::UserAlreadyMemberOfStartup
      flash[:info] = 'The SV ID you supplied is already linked to your startup!'
    rescue Exceptions:: UserAlreadyHasStartup
      flash[:notice] = 'The SV ID you supplied is already linked to another startup. Are you sure you have the right e-mail address?'
    else
      flash[:success] = "SV ID #{params[:email]} has been linked to your startup as founder"
    end

    redirect_to edit_user_startup_path(current_user)
  end

  # POST /add_timeline_event
  def add_timeline_event
    @current_user = current_user
    @startup = @current_user.startup
    @timeline_event = @startup.timeline_events.new timeline_event_params

    if @timeline_event.save
      # render json: @timeline_event,status: :created
      flash[:info] = 'Your new timeline event has been submitted to the SV team for approval!'
      redirect_to @startup
    else
      # render json: @timeline_event.errors, status: :unprocessable_entity
      flash[:error] = 'There seems to be an error in your submission. Please try again!'
      render 'startups/show'
    end
  end

  private

  def apply_now_params
    params.require(:startup).permit(:name, :pitch, :website, :email, :registration_type)
  end

  def startup_params
    params.require(:startup).permit(
      :name, :address, :pitch, :website, :about, :email, :logo, :remote_logo_url, :facebook_link, :twitter_link,
      { category_ids: [] }, { founders_attributes: [:id, :title] },
      :registration_type, :revenue_generated, :presentation_link, :team_size, :women_employees, :slug
    )
  end

  def timeline_event_params
    params.require(:timeline_event).permit(:event_type, :event_on, :description, :image, :link_url)
  end

  def restrict_to_startup_founders
    unless current_user.is_founder?
      raise_not_found
    end
  end

  # A startup that is in unready state shouldn't be allowed to edit its details.
  #
  # @see https://trello.com/c/y4ReClzt
  def disallow_unready_startup
    if current_user.startup.unready?
      flash[:error] = "You haven't completed the incubation process yet. Please complete it before attempting to edit your startup's profile."
      redirect_to current_user
    end
  end
end
