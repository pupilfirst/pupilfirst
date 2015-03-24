namespace :sms do
  desc 'Send out statistics as SMS to configured numbers.'
  task statistics: [:environment] do
    SmsJob.perform_later
  end

  task approved_startups_without_agreement: [:environment] do
    SmsExpiredStartupsJob.perform_later
  end
end
