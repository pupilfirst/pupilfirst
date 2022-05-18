# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback)
    @startup_feedback = startup_feedback
    @students =
      @startup_feedback.timeline_event.founders.map(&:fullname).join(', ')

    send_to =
      startup_feedback
        .timeline_event
        .founders
        .map { |e| "#{e.fullname} <#{e.email}>" }
    @school = startup_feedback.timeline_event.founders.first.school

    subject =
      I18n.t(
        'mailers.startup.feedback_as_email.subject',
        startup_feedback: startup_feedback.faculty.name
      )
    simple_mail(send_to, subject)
  end
end
