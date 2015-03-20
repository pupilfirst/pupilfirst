namespace :meeting_alert do
  desc 'Send out e-mails to user and mentor reminding to return feedback'
    task meeting_feedback: [:environment] do
      MeetingFeedbackReminderJob.perform_later
    end
end
