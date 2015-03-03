class MentorMeetingsCleanupJob < ActiveJob::Base
  queue_as :default

  def perform
    suggested_meetings = MentorMeeting.where(status: [MentorMeeting::STATUS_REQUESTED,MentorMeeting::STATUS_ACCEPTED,MentorMeeting::STATUS_RESCHEDULED])
    expired_suggested_meetings = suggested_meetings.where('suggested_meeting_at < ?', Time.now)
    expired_suggested_meetings.each(&:expire!)

    started_meetings = MentorMeeting.where(status: MentorMeeting::STATUS_STARTED)
    day_old_started_meetings = started_meetings.where('meeting_at < ?', 1.day.from_now)
    day_old_started_meetings.each(&:complete!)
  end

end
