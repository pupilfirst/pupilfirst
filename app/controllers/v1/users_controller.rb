class V1::UsersController < V1::BaseController
  respond_to :json
  skip_before_filter :require_token, only: [:create, :forgot_password]
  before_filter :require_self, only: [:update, :generate_phone_number_verification_code, :verify_phone_number,
    :accept_cofounder_invitation, :reject_cofounder_invitation]#, :connected_contacts, :connect_contact]

  def_param_group :user do
    param :user, Hash, required: true, action_aware: true do
      param :email, String, required: true
      param :password, String, required: true
      param :password_confirmation, String, required: true
      param :fullname, String, required: true
      param :avatar, String
      param :startup_id, Fixnum
      param :title, String
      param :linkedin_url, String
      param :twitter_url, String
      param :born_on, Date
      param :is_founder, [true, false]
      param :din, String
      param :aadhaar, String
      param :is_student, [true, false]
      param :course, String
      param :semester, String
      param :gender, User.valid_gender_values
      param :phone, Fixnum
      param :pin, String
      param :communication_address, String
      param :state, String
      param :year_of_graduation, Fixnum
      param :college_id, Fixnum
      param :district, String
      param :years_of_work_experience, Fixnum
    end
  end

  api :POST, '/users', 'Creates a new user entry, or updates a temporarily created one'
  param_group :user
  see 'users#show', 'GET /users/:id for example response'
  def create
    @user = User.find_by(email: user_params[:email])

    if @user.try(:persisted?)
      if @user.invitation_token
        @user.invitation_token = nil
        @user.assign_attributes user_params
      else
        raise Exceptions::AlreadyCreatedUser, 'User already exists. Use the update route to change attributes.'
      end
    else
      @user = User.new user_params
    end

    if @user.save
      render 'create', status: :created
    else
      render json: { error: @user.errors.to_a.join(', ') }, status: :bad_request
    end
  end

  api :PATCH, '/users/:id', 'Updates an existing user entry'
  param_group :user
  see 'users#show', 'GET /users/:id for example response'
  def update
    @user = current_user
    if @user.update_attributes user_params
      render 'v1/users/show'
    else
      render json: { error: @user.errors.to_a.join(', ') }, status: :bad_request
    end
  end

  api :GET, '/users/:id', 'Retrieve user details'
  description "It retrieves a user's details. Also includes startup details if user belongs to a startup.
If `id` is self, the fields `phone_number` and `phone_verified` are also present."
  example '200 OK
{
  "id": 92,
  "avatar_url": null,
  "fullname": "Mike Wazowski",
  "email": "mike.wazowski@mobme.in",
  "pending_startup_id": null,
  "born_on": "1991-03-25 00:00+0000",
  "startup": null,
  "categories": [
    {
      "id": 1,
      "name": "CATEGORY_NAME",
      "category_type": "user"
    },
    { "more": "categories" }
  ],
  "phone": "+919876543210",
  "phone_verified": true
}
'
  def show
    @extra_info = (params[:id] == 'self') ? true : false
    @user = (params[:id] == 'self') ? current_user : User.find(params[:id])
  end

  api :POST, '/users/forgot_password', 'Sends an email to user to reset password'
  param :email, String, required: true
  error code: 404, desc: 'UserNotFound'
  example '200 OK'
  def forgot_password
    user = User.find_by_email params[:email]
    if user
      user.send_reset_password_instructions
      render nothing: true, status: 200
    else
      raise Exceptions::UserNotFound, 'No user found with that email'
    end
  end

  api :POST, '/users/self/phone_number', 'Send verification code'
  description 'Generates a numeric verification code and sends it to the supplied MSISDN.'
  param :phone, String, required: true
  error code: 422, desc: 'InvalidPhoneNumber'
  example 'Request:
{ "phone": "9876543210" }

200 OK'
  def generate_phone_number_verification_code
    # Generate a 6-digit verification code to send to the phone number.
    code, phone_number = current_user.generate_phone_number_verification_code(params[:phone])

    # SMS the code to the phone number. Currently uses FA format.
    RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for StartupVillage application: #{code}", msisdn: phone_number)

    # Respond with the verification code.
    render nothing: true
  end

  api :PUT, '/users/self/phone_number', 'Verify code'
  description 'Checks wether supplied code matches previously generated code and returns status. If it matches,
the phone number is set to verified.'
  param :phone, String, required: true
  param :code, String, required: true
  error code: 422, desc: 'InvalidPhoneNumber'
  error code: 422, desc: 'PhoneNumberVerificationFailed'
  example 'Request:
{
    "phone": "+919876543210",
    "code": "NUMERIC_VERIFICATION_CODE"
}

200 OK'
  def verify_phone_number
    current_user.verify_phone_number(params[:phone], params[:code])

    render nothing: true
  end

  api :PUT, '/users/:id/cofounder_invitation', 'Accept cofounder invitation'
  description 'The `id` supplied for this route *must* be `self`.

Saves `pending_startup_id` to `startup_id`, linking user to startup as founder and clears `pending_startup_id`.'
  error code: 404, desc: 'UserHasNoPendingStartupInvite'
  error code: 422, desc: 'RestrictedToSelf'
  example '200 OK'
  def accept_cofounder_invitation
    raise Exceptions::UserHasNoPendingStartupInvite, 'User has no pending invite to accept.' unless current_user.pending_startup_id

    # Set the pending startup ID as the User's ID and wipe the pending invite.
    current_user.startup_id = current_user.pending_startup_id
    current_user.pending_startup_id = nil
    current_user.is_founder = true
    current_user.save!

    # Add the user to the list of founders of the startup.
    startup = Startup.find(current_user.startup_id)
    startup.founders << current_user

    # Send out notification to all OTHER founders. Unspec-d.
    founder_ids = startup.founders.map(&:id) - [current_user.id]
    message = "#{current_user.fullname} has accepted your request to become one of the co-founders in your startup!"
    BatchPushNotifyJob.perform_later(founder_ids, 'accept_cofounder_invitation', message, email: current_user.email)

    render nothing: true
  end

  api :DELETE, '/users/self/cofounder_invitation', 'Reject cofounder invitation'
  description 'The `id` supplied for this route *must* be `self`.

Clears `pending_startup_id`.'
  error code: 404, desc: 'UserHasNoPendingStartupInvite'
  error code: 422, desc: 'RestrictedToSelf'
  example '200 OK'
  def reject_cofounder_invitation
    raise Exceptions::UserHasNoPendingStartupInvite, 'User has no pending invite to delete.' unless current_user.pending_startup_id

    # Wipe the pending invite.
    temp_startup_id = current_user.pending_startup_id
    current_user.pending_startup_id = nil
    current_user.save!

    # Send out notification to all other founders. Unspec-d.
    founder_ids = Startup.find(temp_startup_id).founders.map(&:id)
    message = "We're sorry, but #{current_user.fullname} has rejected your request to become one of the co-founders in your startup."
    BatchPushNotifyJob.perform_later(founder_ids, 'reject_cofounder_invitation', message, email: current_user.email)

    render nothing: true
  end

  private

  def user_params
    params.require(:user).permit(:gender,:communication_address, :district, :state, :pin, :linkedin_url, :twitter_url,
      :email, :fullname, :password, :password_confirmation, :avatar, :remote_avatar_url, :born_on,
      :din, :aadhaar, :salutation, :is_student, :college_id, :course, :semester, :title, :place_of_birth,
      :years_of_work_experience, :year_of_graduation)
  end
end
