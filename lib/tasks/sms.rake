namespace :sms do
  desc 'Send out statistics as SMS to configured numbers.'
  task statistics: [:environment] do
    SmsJob.perform_later
  end
end
