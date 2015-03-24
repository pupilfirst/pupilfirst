namespace :sms do
  desc 'Send out statistics as SMS to configured numbers.'
  task statistics: [:environment] do
    SmsJob.perform_later
  end

  desc 'Send out counts of expired startups'
  task expired_startup_agreements: [:environment] do
    SmsExpiredStartupAgreementsJob.perform_later
  end
end
