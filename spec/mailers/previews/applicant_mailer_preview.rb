class ApplicantMailerPreview < ActionMailer::Preview
  def enrollment_verification
    applicant = Applicant.first
    applicant.regenerate_login_token

    ApplicantMailer.enrollment_verification(applicant)
  end
end
