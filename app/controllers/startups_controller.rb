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
    load_startups
    load_filter_options
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

      redirect_to startup_url(@startup)
    else
      # redirect back to startup new form to show errors
      @skip_container = true
      render 'startups/new'
    end
  end

  def show
    @skip_container = true
    @startup = Startup.friendly.find(params[:id])
    if params[:show_feedback].present?
      if current_founder.present?
        @feedback_to_show = @startup.startup_feedback.where(id: params[:show_feedback]).first if @startup.founder?(current_founder)
      else
        session[:referer] = request.original_url
        redirect_to new_founder_session_path, alert: "Please login to continue!"
      end
    end

    @timeline_event = timeline_event_for_builder

    # Should we take the user on a tour?
    @tour = take_on_tour?
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

  def load_startups
    batch_id = params.dig(:startups_filter, :batch)
    batch_scope = batch_id.present? ? Startup.where(batch_id: batch_id) : Startup.batched

    category_id = params.dig(:startups_filter, :category)
    category_scope = category_id.present? ? Startup.joins(:startup_categories).where(startup_categories: { id: category_id }) : Startup.unscoped

    stage = params.dig(:startups_filter, :stage)
    stage_scope = stage.present? ? Startup.where(stage: stage) : Startup.unscoped

    @startups = Startup.approved.merge(batch_scope).merge(category_scope).merge(stage_scope)
  end

  def load_filter_options
    @batches = Startup.available_batches.order('batch_number DESC')
    @categories = StartupCategory.joins(:startups).where.not(startups: { batch_id: nil }).uniq
    @stages = Startup.batched.pluck(:stage).uniq
  end

  def startup_params
    params.require(:startup).permit(
      :legal_registered_name, :address, :pitch, :website, :email, :logo, :remote_logo_url, :facebook_link,
      :twitter_link, :product_name, :product_description,
      { startup_category_ids: [] }, { founders_attributes: [:id] },
      :registration_type, :revenue_generated, :presentation_link, :product_video_link, :wireframe_link, :prototype_link, :team_size, :women_employees, :slug
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

  # A tour of timeline page may be given if user is founder of viewed startup, and the tour param is present.
  def take_on_tour?
    current_founder.present? && current_founder.startup == @startup && current_founder.tour_timeline?
  end

  # If an event_id is available, use that, otherwise supply a new timeline event.
  def timeline_event_for_builder
    if params[:event_id]
      @startup.timeline_events.find(params[:event_id])
    else
      @startup.timeline_events.new
    end
  end
end
