namespace :reminders do
  desc 'Send out e-mails and push notifications for startup agreements that are about to expire.'
  task startup_agreements: [:environment] do
    StartupAgreementReminderJob.perform_later
  end
end
