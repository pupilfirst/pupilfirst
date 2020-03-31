module Applicants
  class EnrollApplicantService
    def initialize(applicant)
      @applicant = applicant
    end

    def execute
      # Make sure we generate a new token.
      @applicant.regenerate_login_token
      # Update the time at which last login mail was sent.
      @applicant.update!(login_mail_sent_at: Time.zone.now)

      UserSessionMailer.send_login_token(@user, url_options).deliver_now
    end
  end
end
