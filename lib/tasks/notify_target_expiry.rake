desc 'Notify startup founders about targets expiry 5 and 2 days before due date'
task notify_target_expiry: [:environment] do
  TargetExpiryNotificationJob.perform_later
end
