class V1::UsersController < V1::BaseController
  respond_to :json
  skip_before_filter :require_token, only: [:create, :forgot_password]
  before_filter :require_self, only: [:generate_phone_number_verification_code, :verify_phone_number]

  def show
    @extra_info = (params[:id] == 'self') ? true : false
    @user = (params[:id] == 'self') ? current_user : User.find(params[:id])
  end

  def create
    @user = User.create user_params
    if @user.save
      render 'create', status: :created
    else
      render json: {error: @user.errors.to_a.join(', ')} , status: :bad_request
    end
  end

  def update
    @user = current_user
    if @user.update_attributes user_params
      render :update
    else
      render json: {error: @user.errors.to_a.join(', ')} , status: :bad_request
    end
  end

  def forgot_password
    user = User.find_by_email params[:email]
    if user
      user.send_reset_password_instructions
      render nothing: true, status: 200
    else
      render json: {error: "No user found with that email"}, status: :unprocessable_entity
    end
  end


  # POST /self/phone_number
  def generate_phone_number_verification_code
    # Generate a 6-digit verification code to send to the phone number.
    code = SecureRandom.random_number(1000000).to_s.ljust(6, '0')

    # TODO: Add phone number validation to UsersController#generate_phone_number_verification_code
    # phone_number = verify params[:phone_number]
    phone_number = params[:phone]

    # Store the phone number and verification code.
    current_user.phone = phone_number
    current_user.phone_verified = false
    current_user.phone_verification_code = code
    current_user.save

    # SMS the code to the phone number. Currently uses FA format.
    RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for StartupVillage application: #{code}", msisdn: phone_number)

    # Respond with the verification code.
    render nothing: true
  end

  # PUT /self/phone_number
  def verify_phone_number
    # Verify incoming phone number
    # phone_number = verify params[:phone]
    phone_number = params[:phone]

    if current_user.phone == phone_number && params[:code] == current_user.phone_verification_code
      # Set the phone number to verified.
      current_user.phone_verified = true
      current_user.phone_verification_code = nil
      current_user.save

      render nothing: true
    else
      render json: { error: 'Invalid verification code'}, status: 422
    end
  end

  private
  def user_params
    params.require(:user).permit(:gender, :communication_address,
                                 :email, :fullname, :password, :password_confirmation, :avatar, :remote_avatar_url, :born_on,
                                 :pan, :din, :aadhaar, :mother_maiden_name, :married, :salutation,
                                 :is_student, :college, :university, :course, :semester, :title,
                                 :religion,:current_occupation, :educational_qualification, :place_of_birth,
                                 address_attributes: [:flat, :building, :street, :area, :town, :state, :pin],
                                 father_attributes: [:first_name, :last_name, :middle_name],
                                 guardian_attributes: [
                                    name_attributes: [:salutation, :first_name, :middle_name, :last_name],
                                    address_attributes: [:flat, :building, :street, :area, :town, :state, :pin] ]
                                 )
  end
end
