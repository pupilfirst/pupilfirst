class MailLoginTokenService

  # @param resource [User/Applicant]
  # @param referer [String, nil] Referer, if any.
  # @param shared_device [true, false] If the user is logging in from a shared device.
  def initialize(resource, referer = nil, shared_device = false)
    @resource = resource
    @referer = referer
    @shared_device = shared_device
  end

  def execute
    # Make sure we generate a new token.
    @resource.regenerate_login_token
    # Update the time at which last login mail was sent.
    @resource.update!(login_mail_sent_at: Time.zone.now)

    case @resource
      when Applicant
        ApplicantMailer.send_login_token(@resource).deliver_now
      when User
        url_options = {
          token: @resource.login_token,
          shared_device: @shared_device
        }
        url_options[:referer] = @referer if @referer.present?
        UserSessionMailer.send_login_token(@resource, url_options).deliver_now
      else
        raise "Undefined class for resource"
    end
  end
end
