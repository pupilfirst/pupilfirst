class AdminUserMailerPreview < ActionMailer::Preview
  def vocalist_ping_results
    message = 'This is a message used to test the preview for the results mail sent to admins.'
    recipient = { channel: '#general' }
    admin_user = AdminUser.first
    errors = nil # should be a CSV, if present.

    AdminUserMailer.vocalist_ping_results(message, recipient, admin_user, errors)
  end

  def google_calendar_invite_success
    admin_user = AdminUser.first
    target = Target.first
    html_link = 'https://google.com'

    AdminUserMailer.google_calendar_invite_success(admin_user, target, html_link)
  end
end
