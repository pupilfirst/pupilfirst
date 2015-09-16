class MeetingFeedbackReminderJob < ActiveJob::Base
  queue_as :default

  def perform
    MentorMeeting.user_feedback_pending.each do |meet|
      MentoringMailer.meeting_feedback_user(meet).deliver_later
    end

    MentorMeeting.mentor_feedback_pending.each do |meet|
      MentoringMailer.meeting_feedback_mentor(meet).deliver_later
    end
  end
end
