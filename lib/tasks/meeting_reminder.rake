namespace :meeting_alert do
  desc 'Send out e-mails to user and mentor on the day of a scheduled meeting'
  task meeting_day: [:environment] do
    MentorMeeting.where('meeting_at > ? AND meeting_at < ?' , Time.now-1.day, 1.day.from_now).each do |meet|
      MentoringMailer.meeting_today_user(meet).deliver_later
      MentoringMailer.meeting_today_mentor(meet).deliver_later
    end
  end

  task remind_to_accept: [:environment] do
  	MentorMeeting.requested.where('meeting_at < ?', 2.days.from_now).each do |meet|
      MentoringMailer.remind_mentor_to_accept(meet).deliver_later
    end
    MentorMeeting.rescheduled.where('meeting_at < ?', 2.days.from_now).each do |meet|
      MentoringMailer.remind_user_to_accept(meet).deliver_later
    end
  end
end
