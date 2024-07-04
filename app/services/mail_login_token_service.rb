class MailLoginTokenService
  # @param referrer [String, nil] referrer, if any.
  # @param shared_device [true, false] If the user is logging in from a shared device.
  def initialize(user, referrer = nil, shared_device = false)
    @user = user
    @referrer = referrer
    @shared_device = shared_device
  end

  def execute
    # Make sure we generate a new hashed login token.
    @user.regenerate_login_token

    input_token =
      AuthenticationToken.generate_input_token(@user, purpose: "sign_in")

    url_options = {
      token: @user.original_login_token,
      shared_device: @shared_device
    }

    url_options[:referrer] = @referrer if @referrer.present?
    UserSessionMailer.send_login_token(
      @user,
      url_options,
      input_token.token
    ).deliver_now
  end
end
