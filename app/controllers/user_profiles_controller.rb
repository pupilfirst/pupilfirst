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
      redirect_to resolve_after_save_path
    else
      render 'edit'
    end
  end

  private

  def resolve_after_save_path
    if current_founder.present?
      student_path(current_founder)

    elsif current_coach.present?
      coach_path(current_coach)
    else
      root_path
    end
  end
end
