class RemindToAcceptJob < ActiveJob::Base

  def perform
    MentorMeeting.requested.where('meeting_at < ?', 2.days.from_now).each do |meet|
      MentoringMailer.remind_mentor_to_accept(meet).deliver_later
    end
    MentorMeeting.rescheduled.where('meeting_at < ?', 2.days.from_now).each do |meet|
      MentoringMailer.remind_user_to_accept(meet).deliver_later
    end
  end

end
