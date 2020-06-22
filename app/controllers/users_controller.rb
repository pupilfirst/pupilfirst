class UsersController < ApplicationController
  before_action :authenticate_user!, except: :delete_account
  layout 'student'

  # GET /dashboard/
  def dashboard
    @user = authorize(current_user)
  end

  def edit
    @user = authorize(current_user)
  end

  # GET /users/delete_account
  def delete_account
    user = Users::ValidateDeletionTokenService.new(params[:token], current_school).authenticate
    if user.present?
      sign_in user
      @token = params[:token]
    else
      flash[:error] = "That link has expired or is invalid. Please try again."
      redirect_to root_path
    end
  end

  # POST /user/upload_avatar
  def upload_avatar
    @form = Users::UploadAvatarForm.new(current_user)
    if @form.validate(params[:user])
      avatar_url = @form.save
      render json: { avatarUrl: avatar_url }
    else
      render 'edit'
    end
  end
end
