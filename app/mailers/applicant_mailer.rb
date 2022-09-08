class ApplicantMailer < SchoolMailer
  def enrollment_verification(applicant)
    @course = applicant.course
    @applicant = applicant
    @school = applicant.course.school
    email_subject_key =
      if @course.processing_url.present?
        'subject_with_processing_url'
      else
        'subject'
      end

    simple_mail(
      @applicant.email,
      I18n.t(
        "mailers.applicant.enrollment_verification.#{email_subject_key}",
        course_name: @course.name
      ),
      enable_reply: false
    )
  end
end
