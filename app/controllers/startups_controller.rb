class StartupsController < InheritedResources::Base
  before_filter :authenticate_user!, except: [:confirm_startup_link, :show, :featured]
  before_filter :restrict_to_startup_founders, only: [:edit, :update]
  before_filter :disallow_unready_startup, only: [:edit, :update]
  after_filter only: [:create] do
    @startup.founders << current_user
    @startup.save
  end

  def index
    @current_user = current_user
    if current_user.startup.present?
      redirect_to action: :show, id: current_user.startup.id
    else
      redirect_to action: :new
    end
  end

  def create
    @startup = Startup.create(apply_now_params.merge({ email: current_user.email }))
    @startup.full_validation = false
    @startup.founders << current_user
    if @startup.save
      # flash[:notice] = "Your startup Application is submited and in pending for approval."
      render :post_create
      StartupMailer.apply_now(@startup).deliver_later
    end
  end

  def show
    @startup = Startup.find(params[:id])
  end

  def edit
    @startup = Startup.find(params[:id])
    @current_user = current_user
    raise_not_found unless current_user.startup.try(:id) == @startup.id
    raise_not_found unless current_user.is_founder?
  end

  def update
    @current_user = current_user
    @startup = Startup.find params[:id]
    @startup.founders.each { |f| f.full_validation = true }
    @startup.validate_frontend_mandatory_fields = true

    if @startup.update(startup_params)
      flash[:notice] = 'Startup details have been updated.'
      redirect_to @startup
    else
      render 'startups/edit'
    end
  end

  def confirm_startup_link
    @startup = Startup.find(params[:id])
    @self = User.find_by_startup_verifier_token(params[:token])
    raise_not_found unless @self
    @startup.founders << @self
    @self.confirm_employee! true
  end

  # def confirm_employee
  #   @startup = Startup.find(params[:id])
  #   @new_employee = User.find_by_startup_verifier_token(params[:token])
  #   raise_not_found unless @new_employee
  #   if request.post?
  #     flash[:notice] = "User was already accepted as startup employee." if @new_employee.startup_link_verifier_id
  #     @new_employee.confirm_employee! params[:is_founder]
  #     message = "Congratulations! You've been approved as #{@new_employee.title} at #{@startup.name}."
  #     UserMailer.accepted_as_employee(@new_employee, @startup).deliver_later
  #     UserPushNotifyJob.new.async.perform(@new_employee.id, :confirm_employee, message)
  #     render :confirm_employee_done
  #   else
  #     @token = params[:token]
  #     render :confirm_employee
  #   end
  # end

  # GET /startups/featured
  def featured
    redirect_to DbConfig.featured_startup
  end

  def apply_now_params
    params.require(:startup).permit(:name, :phone, :pitch, :website, :email, :registration_type)
  end

  def startup_params
    params.require(:startup).permit(
      :name, :address, :pitch, :website, :about, :email, :phone, :logo, { help_from_sv: [] },
      :remote_logo_url, :facebook_link, :twitter_link, :pre_funds, :pre_investers_name, :product_name, :product_description,
      :cool_fact, :help_from_sv, { category_ids: [] }, { founders_attributes: [:id, :title] },
      { startup_before: [:startup_name, :startup_descripition] }, :registration_type,
      :revenue_generated, :presentation_link, :product_progress, :team_size, :women_employees, :incubation_location
    )
  end

  private

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
