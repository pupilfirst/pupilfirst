# Job to be run after midnight every day. It cleans up statuses for meetings.
class MentorMeetingsCleanupJob < ActiveJob::Base
  def perform
    # Expire requested meetings by checking suggested_meeting_at.
    suggested_meetings = MentorMeeting.where(status: [MentorMeeting::STATUS_REQUESTED, MentorMeeting::STATUS_RESCHEDULED])
    expired_suggested_meetings = suggested_meetings.where('suggested_meeting_at < ?', Time.now)
    expired_suggested_meetings.each(&:expire!)

    # Expire accepted meetings by checking meeting_at.
    accepted_meetings = MentorMeeting.where(status: MentorMeeting::STATUS_ACCEPTED)
    expired_accepted_meetings = accepted_meetings.where('meeting_at < ?', Time.now)
    expired_accepted_meetings.each(&:expire!)

    # Complete unfinished started meetings by checking meeting_at.
    started_meetings = MentorMeeting.where(status: MentorMeeting::STATUS_STARTED)
    day_old_started_meetings = started_meetings.where('meeting_at < ?', Time.now)
    day_old_started_meetings.each(&:complete!)
  end
end
