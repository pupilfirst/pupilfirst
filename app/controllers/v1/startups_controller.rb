class V1::StartupsController < V1::BaseController
  skip_before_filter :require_token, only: [:index, :show, :load_suggestions]

  before_filter :require_user_startup_match, only: [:add_founder, :delete_founder, :retrieve_founder, :incubate, :update, :registration]

  def_param_group :startup do
    param :startup, Hash, required: true do
      param :name, String
      param :pitch, String
      param :website, String
      param :registration_type, Startup.valid_registration_types
      param :address, String
      param :state, String
      param :district, String
      param :incubation_location, String
      param :logo, String, 'Image file'
      param :about, String
      param :facebook_link, String
      param :twitter_link, String
      param :product_name, String
      param :product_description, String
      param :categories, String, desc: 'Comma-separated list of category ID-s'
      param :cool_fact, String
      param :revenue_generated, Fixnum
      param :team_size, Fixnum
      param :women_employees, Fixnum
    end
  end

  api :GET, '/startups'
  description 'List all Startups, or by search term and category.'
  param :category, String, desc: 'Search by category'
  param :search_term, String, desc: 'Search by name'
  example '200 OK
[
  {
    "id": 1
    "name": "Startup name"
    "logo_url": "LOGO_URL"
    "pitch": "PITCH"
    "website": "WEBSITE_URL"
    "created_at": "2014-01-22 07:08+0000"
  },
  ...
]'
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

  api :POST, '/startups'
  description 'All fields are optional, since a startup can be created with no information by any logged in user, with
information being filled out slowly, over time and through many stages.'
  param_group :startup
  see 'startups#show', 'GET /startups/:id for example response'
  example '201 Created
{ "startup": "object", "see": "GET method for example" }'
  def create
    raise Exceptions::UserAlreadyHasStartup, "User #{current_user.fullname} is already linked to startup #{current_user.startup.name}" if current_user.startup

    @startup = Startup.new(startup_params.merge({
      email: current_user.email,
      founders: [current_user]
    }))

    # Let's allow startup to be created blank.
    @startup.full_validation = false
    @startup.save

    current_user.update_attributes!(is_founder: true, startup_admin: true)
    @startup.save(validate: false)
    StartupMailer.apply_now(@startup).deliver_later

    respond_with @startup, status: :created
  end

  api :PATCH, '/startups/:id'
  param_group :startup
  example '200 OK
{ "startup": "object", "see": "GET method for example" }'
  see 'startups#show', 'GET /startups/:id for example response'
  def update
    id = params[:id]
    @startup = (id == 'self') ? current_user.startup : Startup.find(id)

    unless @startup.update_attributes!(startup_params)
      render json: { error: @startup.errors.to_a.join(', ') }, status: :bad_request
    end
  end

  api :GET, '/startups/:id'
  description 'Returns all details of a particular startup.'
  example '200 OK
{
  "id": 75,
  "logo_url": null,
  "pitch": null,
  "cool_fact": "Our startup has offices on the moon!",
  "website": null,
  "about": null,
  "email": "mike.wazowski@mobme.in",
  "phone": null,
  "twitter_link": null,
  "facebook_link": null,
  "name": "My Startup",
  "categories": ["category_name_1", "category_name_2"],
  "categories_v2": [
    {
      "id": 1,
      "name": "category_name_1",
      "category_type": "startup"
    },
    {
      "id": 2,
      "name": "category_name_2",
      "category_type": "startup"
    }
  ],
  "created_at": "2014-05-20 10:11+0000",
  "incubation_location": "kochi/visakhapatnam/kozhikode",
  "agreement_first_signed_at": "2014-05-20 10:11+0000",
  "agreement_last_signed_at": "2014-05-20 10:11+0000",
  "agreement_ends_at": "2014-05-20 10:11+0000",
  "physical_incubatee": "true",
  "product_name": "Automated Clown",
  "product_description": "Makes human children laugh their heads off (figuratively).",
  "approval_status": "unready/pending/approved/rejected",
  "registration_type": "private_limited/partnership/llp",
  "address": "multiline\ncommunication\naddress",
  "state": "STATE",
  "district": "DISTRICT",
  "founders": [
    {
      "id": 1,
      "title": null,
      "email": "mike.wazowski@mobme.in",
      "name": "Mike Wazowski",
      "picture_url": null,
      "linkedin_url": null,
      "twitter_url": null
    }
  ]
}'
  def show
    @startup = Startup.find(params[:id])
    respond_to do |f|
      f.json
    end
  end

  api :GET, '/startups/load_suggestions'
  description 'Note that this will returns all startups, including non-verified ones.'
  param :term, String, required: true, desc: 'Search by name'
  example '200 OK
[
  {
    "id": 1,
    "name": "foobar",
    "logo_url": "LOGO_URL"
  },
  ...
]'
  def load_suggestions
    @suggestions = Startup.where("name ilike ?", "#{params[:term]}%")
  end


  api :POST, '/startups/:id/founders'
  param :email, String, required: true
  example 'Request:
{ "email": "james.p.sullivan@mobme.in" }

Response: 200 OK'
  error code: 422, desc: 'UserAlreadyMemberOfStartup'
  error code: 422, desc: 'UserHasPendingStartupInvite'
  error code: 422, desc: 'AuthorizedUserStartupMismatch'
  def add_founder
    user = User.find_or_initialize_cofounder params[:email]

    # Link user to startup as pending founder.
    user.pending_startup_id = params[:id]

    if user.persisted?
      # Send user a notification with co-founder invite message.
      message = "#{@current_user.fullname} wants you to become one of the co-founders of a Startup that #{@current_user.gender == User::GENDER_MALE ? "he's" : "she's"} in the process of creating!"

      # TODO: Spec UserPushNotifyJob.new.async.perform
      UserPushNotifyJob.perform_later(user.id, 'cofounder_invite', message)
    end

    # Save the record.
    user.save_unregistered_user!

    # Send email with co-founder invite message.
    UserMailer.cofounder_request(user.email, current_user).deliver_later

    render nothing: true
  end

  api :DELETE, '/startups/:id/founders'
  param :email, String, required: true
  example 'Request:
{ "email": "james.p.sullivan@mobme.in" }

Response: 200 OK'
  error code: 404, desc: 'FounderMissing'
  error code: 422, desc: 'UserPendingStartupMismatch'
  error code: 422, desc: 'AuthorizedUserStartupMismatch'
  error code: 422, desc: 'UserIsNotPendingFounder'
  def delete_founder
    user = User.find_by(email: params[:email])

    raise Exceptions::FounderMissing, 'Could not find a founder with supplied e-mail ID.' if user.nil?
    raise Exceptions::UserIsNotPendingFounder, 'User is not a pending founder. Cannot be deleted.' if user.pending_startup_id.nil?
    raise Exceptions::UserPendingStartupMismatch, "User is not pending on authorized user's Startup." if user.pending_startup_id != current_user.startup.id

    user.destroy!

    render nothing: true
  end

  api :GET, '/startups/:id/founders'
  description 'Retrieves status of founders depending on supplied e-mail addresses.'
  param :email, String, desc: 'Comma-separated e-mail addresses of previously added co-founders. Discard parameter to
fetch all founders except the caller.'
  example '200 OK
[
  {
    "fullname": "James P Sullivan",
    "email": "james.p.sullivan@mobme.in",
    "status": "pending"
  },
  {
    "fullname": "Boo",
    "email": "boo@mobme.in",
    "status": "accepted"
  },
  {
    "fullname": "Mike Wazowski",
    "email": "mike.wazowski@mobme.in",
    "status": "rejected"
  }
}'
  error code: 404, desc: 'FounderMissing'
  error code: 422, desc: 'AuthorizedUserStartupMismatch'
  def retrieve_founder
    @users = if params[:email]
      User.where(email: params[:email].split(','))
    else
      User.where('pending_startup_id = ? OR startup_id = ?', params[:id], params[:id])
    end

    raise Exceptions::FounderMissing, 'Could not find a founder with supplied e-mail ID.' if @users.empty?
  end

  api :POST, '/startups/:id/incubate'
  description "Sets approval status of startup to `pending`, allowing backend users to go through the submitted startup
details, process the application, and update it's status to either `rejected` or `accepted`."
  param :incubation_location, Startup.valid_incubation_location_values, required: true
  example '200 OK'
  error code: 422, desc: 'StartupInvalidApprovalState'
  def incubate
    startup = Startup.find params[:id]

    # TODO: Verify that the startup is, in fact, ready for incubation? Maybe...

    # Only startups with nil approval status can be moved to pending.
    unless startup.unready?
      raise Exceptions::StartupInvalidApprovalState, "Startup is in '#{startup.approval_status}' state. Cannot incubate."
    end

    # Set startup's incubation_location if its supplied.
    startup.incubation_location = params[:incubation_location] if params[:incubation_location].present?

    # Set startup's approval status to pending.
    startup.approval_status = Startup::APPROVAL_STATUS_PENDING
    startup.save!

    # Send mail to requester about successful submission of incubation request.
    UserMailer.incubation_request_submitted(current_user).deliver_later

    render nothing: true
  end

  private

  def startup_params
    if params[:startup]
      params[:startup].permit(
        :name, :pitch, :website, :registration_type, :address, :state, :district, :incubation_location, :logo, :about,
        :facebook_link, :twitter_link, :product_name, :product_description, :categories, :cool_fact, :revenue_generated,
        :team_size, :women_employees
      )
    else
      {}
    end
  end

  def require_user_startup_match
    # Requested startup must match the authorized user's startup.
    if params[:id].to_i != current_user.startup_id
      raise Exceptions::AuthorizedUserStartupMismatch, "Selected startup does not match User's startup."
    end
  end
end
