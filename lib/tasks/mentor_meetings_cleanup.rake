namespace :mentor_meetings do

  desc 'Update meeting status to reflect expiry or completion upon time-out'
  task cleanup: [:environment] do
    MentorMeetingsCleanupJob.perform_later
  end

end
