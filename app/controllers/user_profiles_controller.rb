class UserProfilesController < ApplicationController
  before_action :authenticate_user!

  # GET /user_profile/edit
  def edit
    @user_profile = authorize(current_user.user_profiles.find_by(school: current_school))
    @form = UserProfiles::EditForm.new(@user_profile)
  end

  # PATCH /user_profile/
  def update
    @user_profile = authorize(current_user.user_profiles.find_by(school: current_school))
    @form = UserProfiles::EditForm.new(@user_profile)

    if @form.validate(params[:user_profiles_edit])
      @form.save!
      flash[:success] = 'Your profile has been updated.'
      redirect_to student_path(id: current_founder.id)
    else
      render 'edit'
    end
  end
end
