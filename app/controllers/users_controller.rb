class UsersController < ApplicationController
  before_action :authenticate_user!
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
    user = Users::ValidateDeletionTokenService.new(params[:token], current_user).authenticate
    if user.present?
      @token = params[:token]
    else
      flash[:error] = "That one-time link has already been used, or is invalid. Please try again."
      redirect_to root_path
    end
  end

  def upload_avatar
    @form = Users::UploadAvatarForm.new(current_user)
    if @form.validate(params[:user])
      avatar_url = @form.save!
      render json: { avatarUrl: avatar_url }
    else
      render 'edit'
    end
  end
end
