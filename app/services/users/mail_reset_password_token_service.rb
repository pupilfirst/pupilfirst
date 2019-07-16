module Users
  # Send a single-use URL to a user that allows them to log into any PupilFirst-hosted domain.
  class MailResetPasswordTokenService
    include RoutesResolvable

    # @param school [School, nil] The current school.
    # @param domain [Domain, nil] The current domain.
    # @param user [User] The user, identified by supplied email address.
    def initialize(school, domain, user)
      @school = school
      @domain = domain
      @user = user
    end

    def execute
      # Make sure we generate a new token.
      @user.regenerate_reset_password_token

      # Update the time at which last reset password mail was sent.
      @user.update!(reset_password_sent_at: Time.zone.now)

      host = @domain&.fqdn || 'www.pupilfirst.com'

      url_options = {
        token: @user.reset_password_token,
        host: host,
        protocol: 'https'
      }

      login_url = url_helpers.reset_password_url(url_options)

      # Send the email with link to sign in.
      UserSessionMailer.send_reset_password_token(@user.email, @school, login_url).deliver_now
    end
  end
end
