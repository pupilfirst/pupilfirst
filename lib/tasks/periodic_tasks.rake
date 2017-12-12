desc 'Spawn jobs for periodic tasks'
task periodic_tasks: :environment do
  # Send reminders to founders for sessions via public Slack.
  Targets::SendSessionRemindersJob.perform_later

  # Ask for feedback about session from faculty and founders.
  Targets::SendSessionFeedbackNotificationJob.perform_later
end
