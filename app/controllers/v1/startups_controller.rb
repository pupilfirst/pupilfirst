class V1::StartupsController < V1::BaseController

  skip_before_filter :require_token, only: [:index, :show, :load_suggestions]

  before_filter :require_user_startup_match, only: [:add_founder, :delete_founder, :retrieve_founder, :incubate, :update, :registration]

  # Returns approved startups.
  def index
    category = Category.startup_category.find_by_name(params['category']) rescue nil
    clause = category ? ["category_id = ?", category.id] : nil
    @startups = if params[:search_term]
      Startup.approved.where("name ilike ?", "#{params[:search_term]}%")
    else
      Startup.joins(:categories).approved.where(clause).order("id desc").uniq
    end
    respond_to do |format|
      format.json
    end
  end

  def create
    raise Exceptions::UserAlreadyHasStartup, "User #{current_user.fullname} is already linked to startup #{current_user.startup.name}" if current_user.startup

    @startup = Startup.new(startup_params.merge({
      email: current_user.email,
      founders: [current_user]
    }))

    # Let's allow startup to be created blank.
    @startup.full_validation = false
    @startup.save

    current_user.verify_self!
    current_user.update_attributes!(is_founder: true)
    @startup.save(validate: false)
    StartupMailer.apply_now(@startup).deliver

    respond_with @startup, status: :created
  end

  def update
    id = params[:id]
    @startup = (id == 'self') ? current_user.startup : Startup.find(id)

    unless @startup.update_attributes!(startup_params)
      render json: { error: @startup.errors.to_a.join(', ') }, status: :bad_request
    end
  end

  def show
    @startup = Startup.find(params[:id])
    respond_to do |f|
      f.json
    end
  end

  def load_suggestions
    @suggestions = Startup.where("name ilike ?", "#{params[:term]}%")
  end

  def link_employee
    @new_employee = current_user
    startup = Startup.find(params[:id])
    @new_employee.update_attributes!(startup: startup, startup_link_verifier_id: nil, title: params[:position])
    StartupMailer.respond_to_new_employee(startup, @new_employee).deliver
    message = "#{@new_employee.fullname} wants to be linked with #{startup.name or "your startup"}. Please check your email to approve."
    startup.founders.each do |f|
      UserPushNotifyJob.new.async.perform(f.id, :fill_personal_info, message)
    end
    # render nothing: true, status: :created
  end

  def partnership_application
    if current_user.startup.partnership_application?
      render json: { error: "Already applied for Partnership" }, status: :bad_request
    else
      current_user.startup.update_attributes!(partnership_application: true)
      StartupMailer.partnership_application(current_user.startup, current_user).deliver
      render nothing: true, status: :created
    end
  end

  # POST /api/startups/:id/registration
  def registration
    if current_user.startup.registration_type
      raise Exceptions::StartupAlreadyRegistered, "Startup is already registered as #{current_user.startup.registration_type}."
    else
      current_user.startup.register(registration_params)
      render nothing: true
    end
  end

  # POST /api/startups/:id/founders
  def add_founder
    user = User.find_or_initialize_cofounder params[:email]

    # Link user to startup as pending founder.
    user.pending_startup_id = params[:id]

    if user.persisted?
      # Send user a notification with co-founder invite message.
      message = "#{@current_user.fullname} wants you to become one of the co-founders of a Startup that #{@current_user.gender == User::GENDER_MALE ? "he's" : "she's"} in the process of creating!"

      # TODO: Spec UserPushNotifyJob.new.async.perform
      UserPushNotifyJob.new.async.perform(user.id, :cofounder_invite, message)
    end

    # Save the record.
    user.save_unregistered_user!

    # Send email with co-founder invite message.
    UserMailer.cofounder_request(user.email, current_user).deliver

    render nothing: true
  end

  # DELETE /api/startups/:id/founders
  def delete_founder
    user = User.find_by(email: params[:email])

    raise Exceptions::FounderMissing, 'Could not find a founder with supplied e-mail ID.' if user.nil?
    raise Exceptions::UserIsNotPendingFounder, 'User is not a pending founder. Cannot be deleted.' if user.pending_startup_id.nil?
    raise Exceptions::UserPendingStartupMismatch, "User is not pending on authorized user's Startup." if user.pending_startup_id != current_user.startup.id

    user.destroy!

    render nothing: true
  end

  # GET /api/startups/:id/founders
  def retrieve_founder
    @users = if params[:email]
      User.where(email: params[:email].split(','))
    else
      User.where('pending_startup_id = ? OR startup_id = ?', params[:id], params[:id])
    end

    raise Exceptions::FounderMissing, 'Could not find a founder with supplied e-mail ID.' if @users.empty?
  end

  # POST /api/startups/:id/incubate
  def incubate
    startup = Startup.find params[:id]

    # TODO: Verify that the startup is, in fact, ready for incubation? Maybe...

    # Only startups with nil approval status can be moved to pending.
    unless startup.unready?
      raise Exceptions::StartupInvalidApprovalState, "Startup is in '#{startup.approval_status}' state. Cannot incubate."
    end

    # Set startup's approval status to pending.
    startup.approval_status = Startup::APPROVAL_STATUS_PENDING
    startup.save!

    render nothing: true
  end

  private
  def startup_params
    if params[:startup]
      params[:startup].permit(:name, :phone, :pitch, :website, :dsc, :transaction_details, :registration_type,
        :address, :state, :district,
        :logo, :about, :phone, :facebook_link, :twitter_link, :product_name, :product_description, :categories, :cool_fact,
        company_names: [:justification, :name],
        police_station: [:city, :line1, :line2, :name, :pin],
        registered_address_attributes: [:flat, :building, :street, :area, :town, :state, :pin]
      )
    else
      {}
    end
  end

  def registration_params
    params.permit(
      :registration_type, :address, :state, :district, :pitch, :total_shares,
      partners: [:fullname, :email, :shares, :cash_contribution, :salary, :managing_director, :operate_bank_account]
    )
  end

  def require_user_startup_match
    # Requested startup must match the authorized user's startup.
    if Startup.find(params[:id]) != current_user.startup
      raise Exceptions::AuthorizedUserStartupMismatch, "Selected startup does not match User's startup."
    end
  end
end
