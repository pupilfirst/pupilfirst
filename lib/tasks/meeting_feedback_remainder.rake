namespace :meeting_alert do 
  desc 'Send out e-mails to user and mentor reminding to return feedback'
  task meeting_feedback: [:environment] do

    MentorMeeting.where(MentorMeeting.where(status: MentorMeeting::STATUS_AWAITFB).each do |meet|
      UserMailer.meeting_feedback_user(meet).deliver_now
      UserMailer.meeting_feedback_mentor(meet).deliver_now
    end
  end
end
