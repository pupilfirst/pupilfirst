namespace :meeting_alert do
  desc 'Send out e-mails to user and mentor reminding to return feedback'
  task meeting_feedback: [:environment] do

    MentorMeeting.user_feedback_pending.each do |meet|
      MentoringMailer.meeting_feedback_user(meet).deliver_later
    end

    MentorMeeting.mentor_feedback_pending.each do |meet|
      MentoringMailer.meeting_feedback_mentor(meet).deliver_later
    end

  end
end
