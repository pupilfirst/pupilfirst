class MentoringMailerPreview < ActionMailer::Preview

  def mentor_verification_ongoing
    MentoringMailer.mentor_verification_ongoing(User.first)
  end

  def remind_user_to_accept
    MentoringMailer.remind_user_to_accept(MentorMeeting.first)
  end

  def remind_mentor_to_accept
    MentoringMailer.remind_mentor_to_accept(MentorMeeting.first)
  end

  def mentor_verified
    MentoringMailer.mentor_verified(Mentor.first)
  end

  def meeting_feedback_user
    MentoringMailer.meeting_feedback_user(MentorMeeting.first)
  end

  def meeting_feedback_mentor
    MentoringMailer.meeting_feedback_mentor(MentorMeeting.first)    
  end

  def meeting_request_cancelled
    MentoringMailer.meeting_request_cancelled(MentorMeeting.first, User.first)
  end

  def meeting_request_rejected
    MentoringMailer.meeting_request_rejected(MentorMeeting.first, User.first)
  end

  def meeting_request_accepted
    MentoringMailer.meeting_request_accepted(MentorMeeting.first, User.first)  
  end

  def meeting_request_rescheduled
    MentoringMailer.meeting_request_rescheduled(MentorMeeting.first)    
  end

  def meeting_today_user
    MentoringMailer.meeting_today_user(MentorMeeting.first)
  end

  def meeting_today_mentor
    MentoringMailer.meeting_today_mentor(MentorMeeting.first)
  end

  def meeting_request_to_mentor
    MentoringMailer.meeting_request_to_mentor(MentorMeeting.first)
  end

end