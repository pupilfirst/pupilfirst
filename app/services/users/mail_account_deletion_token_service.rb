module Users
  class MailAccountDeletionTokenService
    include RoutesResolvable

    def initialize(user)
      @user = user
    end

    def execute
      # Make sure we generate a new token.
      @user.regenerate_delete_account_token

      host = @user.school.domains.where(primary: true).first

      url_options = {
        token: @user.delete_account_token,
        host: host.fqdn,
        protocol: 'https'
      }

      account_deletion_url = url_helpers.delete_account_url(url_options)

      # Send the email with link to delete account.
      UserMailer.delete_account(@user, account_deletion_url).deliver_now
    end
  end
end
