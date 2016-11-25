# TODO: This task has been removed from Heroku scheduler for now. Need to re-introduce after the new target approach is in-place
desc 'Notify startup founders about targets expiry 5 and 2 days before due date'
task notify_target_expiry: [:environment] do
  TargetExpiryNotificationJob.perform_later
end
