# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback, include_grades)
    @startup_feedback = startup_feedback
    @students =
      @startup_feedback.timeline_event.founders.map(&:fullname).join(', ')

    if include_grades
      submission = TimelineEvent.find_by(id: @startup_feedback.timeline_event_id)
      @grading_details = submission.evaluation_criteria.map.with_index { |criteria, index|
        grade_label = criteria[:grade_labels].map {|label| label["label"]}
        grade = submission.timeline_event_grades[index].grade
        {
          name: criteria.name,
          max_grade: criteria.max_grade,
          pass_grade: criteria.pass_grade,
          grade_label: grade_label[grade-1],
          grade: grade,
        }
      }
    end

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
