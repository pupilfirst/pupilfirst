class V1::UsersController < V1::BaseController
  respond_to :json
  skip_before_filter :require_token, only: [:create, :forgot_password]
  before_filter :require_self, only: [:update, :generate_phone_number_verification_code, :verify_phone_number,
    :accept_cofounder_invitation, :reject_cofounder_invitation, :connected_contacts, :connect_contact]

  def show
    @extra_info = (params[:id] == 'self') ? true : false
    @user = (params[:id] == 'self') ? current_user : User.find(params[:id])
  end

  # POST /api/users
  #
  # Creates a new user entry, or updates a temporarily created one.
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

  def update
    @user = current_user
    if @user.update_attributes user_params
      render 'v1/users/show'
    else
      render json: { error: @user.errors.to_a.join(', ') }, status: :bad_request
    end
  end

  def forgot_password
    user = User.find_by_email params[:email]
    if user
      user.send_reset_password_instructions
      render nothing: true, status: 200
    else
      render json: { error: "No user found with that email" }, status: :unprocessable_entity
    end
  end


  # POST /self/phone_number
  def generate_phone_number_verification_code
    # Generate a 6-digit verification code to send to the phone number.
    code, phone_number = current_user.generate_phone_number_verification_code(params[:phone])

    # SMS the code to the phone number. Currently uses FA format.
    RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for StartupVillage application: #{code}", msisdn: phone_number)

    # Respond with the verification code.
    render nothing: true
  end

  # PUT /self/phone_number
  def verify_phone_number
    current_user.verify_phone_number(params[:phone], params[:code])

    render nothing: true
  end

  # PUT /api/users/self/accept_invitation
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
    UserPushNotifyJob.new.async.perform_batch(founder_ids, :accept_cofounder_invitation, message, email: current_user.email)

    render nothing: true
  end

  # DELETE /api/users/self/accept_invitation
  def reject_cofounder_invitation
    raise Exceptions::UserHasNoPendingStartupInvite, 'User has no pending invite to delete.' unless current_user.pending_startup_id

    # Wipe the pending invite.
    temp_startup_id = current_user.pending_startup_id
    current_user.pending_startup_id = nil
    current_user.save!

    # Send out notification to all other founders. Unspec-d.
    founder_ids = Startup.find(temp_startup_id).founders.map(&:id)
    message = "We’re sorry, but #{current_user.fullname} has rejected your request to become one of the co-founders in your startup."
    UserPushNotifyJob.new.async.perform_batch(founder_ids, :reject_cofounder_invitation, message, email: current_user.email)

    render nothing: true
  end

  # GET /api/users/self/contacts
  def connected_contacts
    # Fetch all user connections that were created by SV for user. Also, preload contact (User) data.
    @connections = current_user.connections.where(direction: Connection::DIRECTION_SV_TO_USER).includes(:contact)
  end

  # POST /api/users/self/contacts
  def connect_contact
    User.create_contact!(current_user, contact_params, Connection::DIRECTION_USER_TO_SV)

    render nothing: true
  end

  private

  def contact_params
    params.require(:user).permit(:fullname, :email, :phone, :company, :designation, category_ids: [])
  end

  def user_params
    params.require(:user).permit(:gender, :communication_address, :pin,
      :email, :fullname, :password, :password_confirmation, :avatar, :remote_avatar_url, :born_on,
      :pan, :din, :aadhaar, :mother_maiden_name, :married, :salutation,
      :is_student, :college, :university, :course, :semester, :title,
      :religion, :current_occupation, :educational_qualification, :place_of_birth,
      address_attributes: [:flat, :building, :street, :area, :town, :state, :pin],
      father_attributes: [:first_name, :last_name, :middle_name],
      guardian_attributes: [
        name_attributes: [:salutation, :first_name, :middle_name, :last_name],
        address_attributes: [:flat, :building, :street, :area, :town, :state, :pin]]
    )
  end
end
