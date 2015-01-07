namespace :meeting_alert do 
  desc 'Send out e-mails to user and mentor on the day of a scheduled meeting'
  task meeting_day: [:environment] do

    MentorMeeting.where(MentorMeeting.where('meeting_at > ? AND meeting_at < ?' , Time.now-1.day, 1.day.from_now)
      ).each do |meet|
      UserMailer.meeting_today_user(meet).deliver_now
      UserMailer.meeting_today_mentor(meet).deliver_now
    end
  end
end
