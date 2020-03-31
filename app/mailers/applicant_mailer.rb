class ApplicantMailer < SchoolMailer
  def send_course_enrollment(applicant)
    @applicant = applicant
    @school = applicant.course.school

    simple_roadie_mail(@applicant.email, "Verify Your Email Address", enable_reply: false)
  end
end
