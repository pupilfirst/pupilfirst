module Users
  # Send a single-use URL to a user that allows them to log into any PupilFirst-hosted domain.
  class MailResetPasswordTokenService
    include RoutesResolvable

    # @param school [School, nil] The current school.
    # @param domain [Domain, nil] The current domain.
    # @param user [User] The user, identified by supplied email address.
    # @param referer [String, nil] Referer, if any.
    # @param shared_device [true, false] If the user is logging in from a shared device.
    def initialize(school, domain, user, referer, shared_device)
      @school = school
      @domain = domain
      @user = user
      @referer = referer
      @shared_device = shared_device
    end

    def execute
      # Make sure we generate a new token.
      @user.regenerate_login_token

      # Update the time at which last login mail was sent.
      @user.update!(login_mail_sent_at: Time.zone.now)

      host = @domain&.fqdn || 'www.pupilfirst.com'

      url_options = {
        token: @user.login_token,
        shared_device: @shared_device,
        host: host,
        protocol: 'https'
      }

      url_options[:referer] = @referer if @referer.present?

      login_url = url_helpers.user_token_url(url_options)

      # Send the email with link to sign in.
      UserSessionMailer.send_login_token(@user.email, @school, login_url).deliver_now
    end
  end
end
