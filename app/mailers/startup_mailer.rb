# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback)
    emails_fullnames = startup_feedback.timeline_event.founders.map { |e| {"#{e.fullname} <#{e.email}>" => {"fullname" => e.fullname, "email" => e.email}} }
    emails_fullnames.each do | student |
        student.each do |send_to, values|
          send_single_email(send_to, values, startup_feedback)
        end
    end
  end

  def send_single_email(send_to, values, startup_feedback)
    @startup_feedback = startup_feedback
    @student_fullname = values["fullname"]
    @email = values["email"]
    @school = startup_feedback.startup.school
    subject = "New feedback from #{startup_feedback.faculty.name} on your submission"
    simple_mail(send_to, subject)
  end

end
