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

	private
	def user_params
		params.require(:user).permit(
		                             :email, :fullname, :password, :password_confirmation, :avatar, :remote_avatar_url, :born_on,
		                             :pan, :din, :aadhaar, :mother_maiden_name, :married, :salutation,
		                             :religion,:current_occupation, :educational_qualification, :place_of_birth,
		                             other_name_attributes: [:first_name, :middle_name, :last_name],
		                             address_attributes: [:flat, :building, :street, :area, :town, :state, :pin],
		                             father_attributes: [:first_name, :last_name, :middle_name],
		                             guardian_attributes: [
		                             		name_attributes: [:first_name, :middle_name, :last_name],
		                             		address_attributes: [:flat, :building, :street, :area, :town, :state, :pin] ]
		                             )
	end
end
