# Mails sent out to admin users.
class AdminUserMailer < ApplicationMailer
  def vocalist_ping_results(message, recipient, admin_user, errors)
    @message = message
    @recipient = recipient
    @admin_user = admin_user
    @errors = errors
    mail(to: admin_user.email, subject: 'Vocalist ping job complete')
  end
end
