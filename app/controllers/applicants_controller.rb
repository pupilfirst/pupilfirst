class ApplicantsController < ApplicationController
  # GET /applicants/:token/enroll
  def enroll
    @applicant = Applicant.find_by(login_token: params[:token])

    if valid_applicant?
      @applicant.update!(email_verified: true)

      redirect_to resolve_applicant_path
    else
      flash[:error] =
        'That one-time link has expired, or is invalid. If you have already completed enrollment, please sign in.'
      redirect_to new_user_session_path
    end
  end

  private

  def resolve_applicant_path
    if @applicant.course.processing_url.blank?
      student =
        Applicants::CreateStudentService
          .new(@applicant)
          .create([session[:applicant_tag] || 'Public Signup'])
      sign_in student.user
      flash[:success] = "Welcome to #{current_school.name}!"
      after_sign_in_path_for(student.user)
    else
      @applicant
        .course
        .processing_url
        .gsub('${course_id}', @applicant.course_id.to_s)
        .gsub('${applicant_id}', @applicant.id.to_s)
        .gsub('${email}', @applicant.email)
        .gsub('${name}', @applicant.name)
    end
  end

  def valid_applicant?
    public_courses = current_school.courses.where(public_signup: true)
    @applicant.present? && public_courses.exists?(id: @applicant.course_id)
  end
end
