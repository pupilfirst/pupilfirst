namespace :meeting_alert do
  desc 'Send out e-mails to user and mentor on the day of a scheduled meeting'
  task meeting_day: [:environment] do
    MeetingDayReminderJob.perform_later
  end

  task remind_to_accept: [:environment] do
    RemindToAcceptJob.perform_later
  end
end
