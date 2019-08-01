module Applicants
  class MailLoginTokenService
    include RoutesResolvable

    def initialize(applicant)
      @applicant = applicant
    end

    def execute
      # Make sure we generate a new token.
      @applicant.regenerate_login_token

      # Update the time at which last login token mail was sent.
      @applicant.update!(login_token_sent_at: Time.zone.now)

      url_options = {
        token: @applicant.login_token,
        host: @applicant.course.school.domains.where(primary: true).first.fqdn,
        protocol: 'https'
      }

      login_url = url_helpers.enroll_url(url_options)

      # Send the email with link to sign in.
      ApplicantMailer.send_login_token(@applicant, login_url).deliver_now
    end
  end
end
