class ApplicantsController < ApplicationController
  # GET /enroll/:token
  def enroll
    @applicant = authorize(Applicant.find_by(login_token: params[:token]))
    if @applicant.present?
      user = Applicants::CreateStudentService.new(@applicant).execute
      sign_in user
      flash[:success] = 'User authentication completed, You can start learning'
      redirect_to after_sign_in_path_for(user)
    else
      flash[:error] = 'User authentication failed. The link you followed appears to be invalid.'
      redirect_to new_user_session_path
    end
  end
end
