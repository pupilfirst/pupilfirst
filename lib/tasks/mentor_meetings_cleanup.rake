namespace :mentor_meetings do

  desc 'Set suggested meeting requests that are more than one day past tentative date to expired'
  task expire: [:environment] do
    suggested_meetings = MentorMeeting.where(status: [MentorMeeting::STATUS_REQUESTED,MentorMeeting::STATUS_ACCEPTED,MentorMeeting::STATUS_RESCHEDULED]) 
    expired_suggested_meetings = suggested_meetings.where('suggested_meeting_at < ?', Time.now)
    expired_suggested_meetings.each(&:expire!)
  end

  task complete: [:environment] do
    started_meetings = MentorMeeting.where(status: MentorMeeting::STATUS_STARTED)
    day_old_started_meetings = started_meetings.where('meeting_at < ?', 1.day.from_now)
    day_old_started_meetings.each(&:complete!)
  end

end
