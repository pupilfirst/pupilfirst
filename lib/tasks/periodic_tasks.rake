desc 'Spawn jobs for periodic tasks'
task period_tasks: :environment do
  # Send reminders to founders for sessions via public Slack.
  Targets::SendSessionRemindersJob.perform_later

  # Ask for feedback about session from faculty and founders.
  Targets::SendSessionFeedbackNotificationsJob.perform_later
end
