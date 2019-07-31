class ApplicantsController < ApplicationController
  # GET /enroll/:token
  def enroll
    @applicant = Applicant.find_by(login_token: params[:token])
    if valid_applicant?
      user = Applicants::CreateStudentService.new(@applicant).execute
      sign_in user
      flash[:success] = 'User authentication successfully'
      redirect_to after_sign_in_path_for(user)
    else
      flash[:error] = 'User authentication failed. The link you followed appears to be invalid.'
      redirect_to new_user_session_path
    end
  end

  private

  def valid_applicant?
    if @applicant.present?
      @applicant.course.in? current_school.courses.where(enable_public_signup: true)
    else
      false
    end
  end
end
