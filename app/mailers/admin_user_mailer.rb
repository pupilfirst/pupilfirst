# Mails sent out to Pupilfirst super-admin users.
#
# TODO: The AdminUserMailer class should be removed.
class AdminUserMailer < PupilfirstMailer
  def vocalist_ping_results(message, recipient, admin_user, errors)
    @message = message
    @recipient = recipient
    @admin_user = admin_user
    @errors = errors

    if @errors.present?
      filename = "errors-#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
      attachments[filename] = @errors
    end

    roadie_mail(to: admin_user.email, subject: 'Vocalist ping job complete')
  end
end
