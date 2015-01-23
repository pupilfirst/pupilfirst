# TODO: Spec rake mentor_meetings:expire
namespace :mentor_meetings do
  desc 'Set meetings that are more than one day past agreed date to expired'
  task expire: [:environment] do
    non_expired_meetings = MentorMeeting.where.not(status: MentorMeeting::STATUS_EXPIRED)
    expired_fixed_meetings = non_expired_meetings.where('meeting_at < ?', 1.day.ago)
    expired_suggested_meetings = non_expired_meetings.where('meeting_at is NULL').where('suggested_meeting_at < ?', Time.now)

    [expired_fixed_meetings + expired_suggested_meetings].each do |expired_meeting|
      expired_meeting.update!(status: MentorMeeting::STATUS_EXPIRED)
    end
  end
end
