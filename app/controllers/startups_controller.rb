class StartupsController < InheritedResources::Base
  before_filter :authenticate_user!, except: [:show, :featured, :itraveller]
  before_filter :restrict_to_startup_founders, only: [:edit, :update]
  before_filter :disallow_unready_startup, only: [:edit, :update]
  after_filter only: [:create] do
    @startup.founders << current_user
    @startup.save
  end

  layout 'homepage', only: [:itraveller, :show]

  def new
    if !current_user.phone_verified?
      flash[:notice] = 'Please enter and verify your phone number to continue.'

      session[:referer] = new_startup_url
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
    @startups = Startup.agreement_live
  end

  def create

  end

  def show
    @startup = Startup.find(params[:id])
    @events = @startup.timeline_events.order(:event_on, :updated_at).reverse_order
  end

  def edit
    @startup = Startup.find(params[:id])
    @current_user = current_user
    raise_not_found unless current_user.startup.try(:id) == @startup.id
    raise_not_found unless current_user.is_founder?
  end

  def update
    # @current_user = current_user
    # @startup = Startup.find params[:id]
    # @startup.founders.each { |f| f.full_validation = true }
    # @startup.validate_web_mandatory_fields = true

    # if @startup.update(startup_params)
    #   flash[:notice] = 'Startup details have been updated.'
    #   redirect_to @startup
    # else
    #   render 'startups/edit'
    # end
  end

  # GET /startups/featured
  def featured
    redirect_to DbConfig.featured_startup
  end

  private

  def apply_now_params
    params.require(:startup).permit(:name, :pitch, :website, :email, :registration_type)
  end

  def startup_params
    params.require(:startup).permit(
      :name, :address, :pitch, :website, :about, :email, :phone, :logo, :remote_logo_url, :facebook_link, :twitter_link,
      :product_name, :product_description, :cool_fact, { category_ids: [] }, { founders_attributes: [:id, :title] },
      :registration_type, :revenue_generated, :presentation_link, :product_progress, :team_size, :women_employees,
      :incubation_location
    )
  end

  def restrict_to_startup_founders
    if current_user.startup.try(:id) != params[:id].to_i || !current_user.is_founder?
      raise_not_found
    end
  end

  # A startup that is in unready state shouldn't be allowed to edit its details.
  #
  # @see https://trello.com/c/y4ReClzt
  def disallow_unready_startup
    if current_user.startup.unready?
      flash[:alert] = "Please submit your incubation application via our Mobile app before attempting to edit your startup's details."
      redirect_to startup_path(current_user.startup)
    end
  end
end
