# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback)
    emails_fullnames = startup_feedback.timeline_event.founders.map { |e| [e.fullname, e.email] }
    emails_fullnames.each do | fullname, email |
      send_to = "#{fullname} <#{email}>"
      send_single_email(send_to, fullname, email, startup_feedback)
    end
  end

  def send_single_email(send_to, fullname, email, startup_feedback)
    @startup_feedback = startup_feedback
    @student_fullname = fullname
    @email = email
    @school = startup_feedback.startup.school
    subject = "New feedback from #{startup_feedback.faculty.name} on your submission"
    simple_mail(send_to, subject)
  end

end
