class ApplicantMailer < SchoolMailer
  def send_login_token(applicant, login_url)
    @applicant = applicant
    @login_url = login_url
    @school = applicant.course.school

    simple_roadie_mail(@applicant.email, "Verify Your Email Address", enable_reply: false)
  end
end
