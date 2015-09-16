class MeetingDayReminderJob < ActiveJob::Base
  queue_as :default

  def perform
    MentorMeeting.where('meeting_at > ? AND meeting_at < ?', 1.day.ago, 1.day.from_now).each do |meet|
      MentoringMailer.meeting_today_user(meet).deliver_later
      MentoringMailer.meeting_today_mentor(meet).deliver_later
    end
  end
end
