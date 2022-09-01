module Users
  class MailUpdateEmailTokenService
    include RoutesResolvable

    def initialize(user, new_email)
      @school = user.school
      @domain = @school.domains.primary
      @user = user
      @new_email = new_email
    end

    def execute
      @user.regenerate_update_email_token

      @user.update!(
        update_email_token_sent_at: Time.zone.now,
        new_email: @new_email
      )

      url_options = {
        token: @user.update_email_token,
        host: @domain.fqdn,
        protocol: 'https'
      }

      update_email_url = url_helpers.update_email_url(url_options)

      # Send the email with link to update email.
      UserMailer.update_email_token(@user, @new_email, update_email_url)
        .deliver_now
    end
  end
end
