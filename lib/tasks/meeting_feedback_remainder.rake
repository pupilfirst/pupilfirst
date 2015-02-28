namespace :meeting_alert do
  desc 'Send out e-mails to user and mentor reminding to return feedback'
  task meeting_feedback: [:environment] do

    # TODO: Fix this. There is no MentorMeeting::STATUS_AWAITING_FEEDBACK.
    MentorMeeting.where(status: MentorMeeting::STATUS_AWAITING_FEEDBACK).each do |meet|
      MentoringMailer.meeting_feedback_user(meet).deliver_later
      MentoringMailer.meeting_feedback_mentor(meet).deliver_later
    end
  end
end
