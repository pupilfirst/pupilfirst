class MentoringMailer < ApplicationMailer

  default from: "SV App <no-reply@svlabs.in>", cc: "outgoing@svlabs.in"

  def mentor_verification_ongoing(current_user)
    @current_user = current_user
    mail to:@current_user.email, subject: 'Mentor profile being verified'
  end

  def remind_user_to_accept(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.user.email, subject: 'Reminder: Meeting Reschedule pending confirmation'
  end

  def remind_mentor_to_accept(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.mentor.user.email, subject: 'Reminder: Meeting Request pending acceptance'
  end

  def mentor_verified(mentor)
    @mentor = mentor
    mail to:@mentor.user.email, subject: 'Your mentor account has been verified'
  end

  def meeting_feedback_user(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.user.email, subject: 'Reminder: Feedback on mentoring session'
  end

  def meeting_feedback_mentor(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.mentor.user.email, subject: 'Reminder: Feedback on mentoring session'
  end

  def meeting_request_cancelled(mentor_meeting,recipient)
    @mentor_meeting = mentor_meeting
    @recipient = recipient
    mail to:recipient.email, subject: 'Meeting cancelled by ' + @mentor_meeting.guest(recipient).fullname
  end

  def meeting_request_rejected(mentor_meeting,recipient)
    @mentor_meeting = mentor_meeting
    @recipient = recipient
    mail to:recipient.email, subject: 'Meeting rejected by ' + @mentor_meeting.guest(recipient).fullname
  end

  def meeting_request_accepted(mentor_meeting,recipient)
    @mentor_meeting = mentor_meeting
    @recipient = recipient
    mail to:recipient.email, subject: 'Meeting accepted by ' + @mentor_meeting.guest(recipient).fullname
  end

  def meeting_request_rescheduled(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.user.email, subject: 'Meeting request rescheduled by ' + @mentor_meeting.mentor.user.fullname
  end

  def meeting_today_user(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.user.email, subject: 'Reminder: Meeting with' + @mentor_meeting.mentor.user.fullname
  end

  def meeting_today_mentor(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.mentor.user.email, subject: 'Reminder: Meeting with #{@mentor_meeting.user.fullname}@#{@mentor_meeting.user.startup.name}'
  end

  def meeting_request_to_mentor(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to: @mentor_meeting.mentor.user.email, subject: 'Request for mentoring'
  end

end
