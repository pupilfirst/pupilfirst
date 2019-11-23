class UsersController < ApplicationController
  before_action :authenticate_user!
  layout 'student', only: :home_v2

  # GET /home/
  def home
    @user = authorize(current_user)
  end

  def home_v2
    @user = authorize(current_user)
  end

  # GET /user/edit
  def edit
    @form = Users::EditForm.new(current_user)
  end

  # PATCH /user
  def update
    @form = Users::EditForm.new(current_user)

    if @form.validate(params[:users_edit])
      @form.save!
      flash[:success] = 'Your profile has been updated.'
      redirect_back(fallback_location: home_path)
    else
      render 'edit'
    end
  end
end
