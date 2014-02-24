class V1::UsersController < V1::BaseController
  respond_to :json

	def show
		@user = User.find params[:id]
		@user = User.find params[:id]
	end

	def create
		@user = User.create user_params
		if @user.save
	    render 'create', status: :created
		else
	    render json: @user.errors, status: :bad_request
		end
	end

	def forgot_password
		user = User.find_by_email params[:email]
		user.send_reset_password_instructions
		render nothing: true, status: 200
	end

	private
	def user_params
		params.require(:user).permit :email, :fullname, :password, :password_confirmation, :skip_password, :avatar, :born_on, social_ids_attributes: [[:social_id, :social_token, :permission, :provider]]
	end
end
