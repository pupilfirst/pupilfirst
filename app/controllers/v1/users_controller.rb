class V1::UsersController < V1::BaseController
  respond_to :json
  skip_before_filter :require_token, only: [:create, :forgot_password]

	def show
		@user = User.find params[:id]
	end

	def create
		@user = User.create user_params
		if @user.save
	    render 'create', status: :created
		else
	    render json: @user.errors.join(', '), status: :bad_request
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
		params.require(:user).permit :email, :fullname, :password, :password_confirmation, :avatar, :remote_avatar_url, :born_on
	end
end
