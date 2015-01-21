class UserMailer < ActionMailer::Base
  default from: "SV App <no-reply@svlabs.in>", cc: "outgoing@svlabs.in"

  def meeting_feedback_user(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.user.email, subject: 'Reminder: Feedback on mentoring session' 
  end

  def meeting_feedback_mentor(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.mentor.user.email, subject: 'Reminder: Feedback on mentoring session' 
  end

  def meeting_request_rejected(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.user.email, subject: 'Meeting request rejected by ' + @mentor_meeting.mentor.user.fullname
  end

  def meeting_request_accepted(mentor_meeting)
    @mentor_meeting = mentor_meeting
    mail to:@mentor_meeting.user.email, subject: 'Meeting request accepted by ' + @mentor_meeting.mentor.user.fullname
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

  def reminder_to_complete_founder_profile(user)
    @user = user
    mail to: @user.email, subject: 'Reminder to fill up founder profile'
  end

  def confirm_partnership_formation(partnership, requesting_user)
    @partnership = partnership
    @requesting_user = requesting_user

    mail to: @partnership.user.email, subject: 'Request to form partnership'
  end

  def cofounder_request(cofounder, current_user)
    @current_user = current_user
    mail(to: cofounder, subject: 'SVApp: You have been invited to join a Startup!')
  end

  def incubation_request_submitted(current_user)
    @current_user = current_user
    mail(to: current_user.email, subject: 'You have successfully submitted your request for incubation at Startup Village.')
  end

  def inform_sep_submition(user)
    @user = user
    mail(to: student_contact, subject: "sep submited")
  end

  def request_to_be_a_founder(user, startup, current_user)
    @startup = startup
    @user = user
    @current_user = current_user
    mail(to: user.email, subject: "Founder at #{@startup.name}? Please approve")
  end

  def inform_student_contact

  end

  def inform_student

  end

  def new_sep_notification(user)
    @user = user
    mail(to: student_contact, cc: "incoming@svlabs.in", subject: "New SEP applicant.")
  end

  def send_sep_certificate(user, file_path)
    attachments['sep_certificate.pdf'] = File.read(file_path)
    mail(to: user.email, body: "PFA", subject: "SEP from Startup Village")
  end

  def accepted_as_employee(user, startup)
    @startup = startup
    @user = user
    mail(to: user.email, subject: "You're approved at #{@startup.name}")
  end

  def password_changed(user)
    @user = user
    mail(to: user.email, subject: "Your password has been changed")
  end

private
  def student_contact
    I18n.t("startup_village.student_contact.#{Rails.env}") or 'info@svlabs.in'
  end

end
