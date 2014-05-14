class V1::UsersController < V1::BaseController
  respond_to :json
  skip_before_filter :require_token, only: [:create, :forgot_password]

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

  # POST /phone_number_verification
  def phone_number_verification
    # Generate a 6-digit verification code to send to the phone number.
    code = SecureRandom.random_number(1000000).to_s.ljust(6, '0')

    # SMS the code to the phone number.
    # TODO: Change this to appropriate form when provider URL is available.
    RestClient.post(APP_CONFIG[:sms_provider_url], message: "Verification code for StartupVillage application: #{code}")

    # Respond with the verification code.
    render json: { code: code }
  end

  private
  def user_params
    params.require(:user).permit(:gender, :communication_address, :phone,
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
