class StartupsController < ApplicationController
  before_filter :authenticate_founder!, except: [:show, :index]
  before_filter :restrict_to_startup_founders, only: [:edit, :update, :add_founder]
  before_filter :restrict_to_startup_admin, only: [:remove_founder]

  after_filter only: [:create] do
    @startup.founders << current_founder
    @startup.save
  end

  # GET /startups
  def index
    @batches = Startup.available_batches.order('batch_number DESC')
    @skip_container = true
  end

  def new
    @skip_container = true
    if current_founder.phone.blank?
      session[:referer] = new_founder_startup_url
      redirect_to phone_founder_path
      return
    end

    if current_founder.startup&.approved?
      flash[:alert] = "You already have an approved startup on SV.CO!"
      redirect_to startup_url(current_founder.startup)
    end

    @startup = Startup.new
  end

  def create
    @startup = Startup.new startup_registration_params

    # setting attributes required for registration-specific validations
    @startup.being_registered = true
    @startup.team_lead_email = current_founder.email

    # copy over the batch from current_founders invited_batch
    @startup.batch = current_founder.invited_batch

    if @startup.save
      # reset being_registered flag to prevent repeating cofounder validations
      @startup.being_registered = false

      # add the team lead
      @startup.add_team_lead! current_founder

      # add cofounders
      @startup.add_cofounders!

      # mark as approved
      @startup.approve!

      # generate a more meaningful slug
      @startup.regenerate_slug!

      # prepopulate the timeline with a 'Joined SV.CO' entry
      @startup.prepopulate_timeline!

      flash[:success] = "Your startup has been registered successfully!"
      redirect_to @startup
    else
      # redirect back to startup new form to show errors
      @skip_container = true
      render 'startups/new'
    end
  end

  def show
    @startup = Startup.friendly.find(params[:id])

    # if non-founders try to visit feedback, show an alert
    if params[:showFeedbackFor].present?
      flash[:alert] = "Only logged-in founders of the startup can view feedback" unless current_founder && @startup.founder?(current_founder)
    end

    @timeline_event = if params[:event_id]
      @startup.timeline_events.find(params[:event_id])
    else
      @startup.timeline_events.new
    end
  end

  def edit
    @startup = current_founder.startup
  end

  def update
    @current_founder = current_founder
    @startup = @current_founder.startup
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
      current_founder.add_as_founder_to_startup!(params[:cofounder][:email])
    rescue Exceptions::FounderNotFound
      flash[:error] = "Couldn't find a founder with the SV.CO ID you supplied. Please verify founder's registered email address."
    rescue Exceptions::FounderAlreadyMemberOfStartup
      flash[:info] = 'The SV.CO ID you supplied is already linked to your startup!'
    rescue Exceptions::FounderAlreadyHasStartup
      flash[:notice] = 'The SV.CO ID you supplied is already linked to another startup. Are you sure you have the right e-mail address?'
    else
      flash[:success] = "SV.CO ID #{params[:email]} has been linked to your startup as founder"
    end

    redirect_to edit_founder_startup_path
  end

  # PATCH /remove_founder
  def remove_founder
    founder_to_remove = current_founder.startup.founders.find_by id: params[:founder_id]
    if founder_to_remove.present?
      founder_to_remove.update(startup_id: nil)
      flash.now[:success] = "The founder was successfully removed from your startup!"
    else
      flash.now[:error] = "There was an error in removing the founder!"
    end
    redirect_to :back
  end

  # DELETE /founders/:id/startup/destroy
  def destroy
    @startup = current_founder.startup

    if current_founder.startup_admin
      if current_founder.startup_admin && current_founder.valid_password?(startup_destroy_params[:password])
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
      :legal_registered_name, :address, :pitch, :website, :email, :logo, :remote_logo_url, :facebook_link,
      :twitter_link, :product_name, :product_description,
      { startup_category_ids: [] }, { founders_attributes: [:id] },
      :registration_type, :revenue_generated, :presentation_link, :product_video, :wireframe_link, :prototype_link, :team_size, :women_employees, :slug
    )
  end

  def startup_registration_params
    params.require(:startup).permit(:product_name, :team_size, :cofounder_1_email, :cofounder_2_email, :cofounder_3_email,
      :cofounder_4_email)
  end

  def startup_destroy_params
    params.require(:startup).permit(:password)
  end

  def restrict_to_startup_founders
    return if current_founder
    raise_not_found
  end

  def restrict_to_startup_admin
    return if current_founder.startup_admin?
    raise_not_found
  end
end
