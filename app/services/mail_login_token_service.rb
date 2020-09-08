class MailLoginTokenService
  # @param referrer [String, nil] referrer, if any.
  # @param shared_device [true, false] If the user is logging in from a shared device.
  def initialize(user, referrer = nil, shared_device = false)
    @user = user
    @referrer = referrer
    @shared_device = shared_device
  end

  def execute
    # Make sure we generate a new token.
    @user.regenerate_login_token
    # Update the time at which last login mail was sent.
    @user.update!(login_mail_sent_at: Time.zone.now)

    url_options = {
      token: @user.login_token,
      shared_device: @shared_device
    }
    url_options[:referrer] = @referrer if @referrer.present?
    UserSessionMailer.send_login_token(@user, url_options).deliver_now
  end
end
