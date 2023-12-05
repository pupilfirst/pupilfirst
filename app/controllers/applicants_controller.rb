class ApplicantsController < ApplicationController
  # GET /applicants/:token/enroll
  def enroll
    login_token_digest = Digest::SHA2.base64digest(params[:token])
    @applicant = Applicant.find_by(login_token_digest: login_token_digest)

    if valid_applicant?
      @applicant.update!(email_verified: true)

      redirect_to resolve_applicant_path, allow_other_host: true
    else
      flash[:error] = t(".link_expired")
      redirect_to new_user_session_path
    end
  end

  private

  def resolve_applicant_path
    if @applicant.course.processing_url.blank?
      student =
        Applicants::CreateStudentService.new(@applicant).create(
          [session[:applicant_tag] || "Public Signup"]
        )
      sign_in student.user
      flash[:success] = t(".welcome", school_name: current_school.name)
      after_sign_in_path_for(student.user)
    else
      @applicant
        .course
        .processing_url
        .gsub("${course_id}", @applicant.course_id.to_s)
        .gsub("${applicant_id}", @applicant.id.to_s)
        .gsub("${email}", ERB::Util.url_encode(@applicant.email))
        .gsub("${name}", ERB::Util.url_encode(@applicant.name))
    end
  end

  def valid_applicant?
    public_courses = current_school.courses.where(public_signup: true)
    @applicant.present? && public_courses.exists?(id: @applicant.course_id)
  end
end
