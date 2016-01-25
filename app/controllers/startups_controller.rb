class StartupsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :restrict_to_startup_founders, only: [:edit, :update, :add_founder]
  before_filter :restrict_to_startup_admin, only: [:remove_founder]

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

    if current_user.startup&.approved?
      flash[:alert] = "You already have an approved startup on SV.CO!"
      redirect_to startup_url(current_user.startup)
    end

    @startup = Startup.new
  end

  def create
    @startup = Startup.new startup_registration_params

    if @startup.save
      # add the team lead
      add_current_user_as_team_lead(@startup)

      # add cofounders
      add_cofounders(@startup)

      # mark as approved
      @startup.approve!

      # generate a more meaningful slug
      @startup.regenerate_slug!

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

  def startup_registration_params
    params.require(:startup).permit(:name, :team_size, :cofounder_1_email, :cofounder_2_email, :cofounder_3_email,
      :cofounder_4_email, :being_registered, :team_lead_email)
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

  def add_current_user_as_team_lead(startup)
    startup.founders << current_user
    current_user.update!(startup_admin: true)
  end

  def add_cofounders(startup)
    startup.cofounder_emails.each do |email|
      next if email.blank?
      startup.founders << User.find_by(email: email)
    end

    # reset being_registered flag to prevent repeating cofounder validations
    startup.being_registered = false
  end
end
