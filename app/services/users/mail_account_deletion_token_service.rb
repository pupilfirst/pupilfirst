module Users
  class MailAccountDeletionTokenService
    include RoutesResolvable

    def initialize(user)
      @user = user
    end

    def execute
      # Make sure we generate a new token.
      @user.regenerate_delete_account_token
      @user.update!(delete_account_sent_at: Time.zone.now)

      host = @user.school.domains.where(primary: true).first

      url_options = {
        token: @user.delete_account_token_original,
        host: host.fqdn,
        protocol: 'https'
      }

      account_deletion_url = url_helpers.delete_account_url(url_options)

      # Send the email with link to delete account.
      UserMailer.delete_account_token(@user, account_deletion_url).deliver_later
    end
  end
end
