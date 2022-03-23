# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback)
    @startup_feedback = startup_feedback

    # it's intended to send only to one recipient
    send_to = startup_feedback.timeline_event.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    @school = startup_feedback.startup.school
    @student_fullname = startup_feedback.timeline_event.founders.first.fullname

    subject = "New feedback from #{startup_feedback.faculty.name} on your submission"
    simple_mail(send_to, subject)
  end
end
