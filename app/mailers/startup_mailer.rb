# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback, include_grades)
    @startup_feedback = startup_feedback
    @students =
      @startup_feedback.timeline_event.students.map(&:fullname).join(', ')
    @grading_details = grading_details(startup_feedback, include_grades)

    send_to =
      startup_feedback
        .timeline_event
        .students
        .map { |e| "#{e.fullname} <#{e.email}>" }
    @school = startup_feedback.timeline_event.students.first.school

    subject =
      I18n.t(
        'mailers.startup.feedback_as_email.subject',
        startup_feedback: startup_feedback.faculty.name
      )
    simple_mail(send_to, subject)
  end

  def grading_details(startup_feedback, include_grades)
    return unless include_grades

    timeline_event_grades =
      startup_feedback.timeline_event.timeline_event_grades.includes(
        :evaluation_criterion
      )

    timeline_event_grades.map { |te_grade|
      criteria_name = te_grade.evaluation_criterion.name
      grade = te_grade.grade
      grade_icon = grade >= te_grade.evaluation_criterion.pass_grade ? '✅' : '❌'
      grade_label =
        te_grade
          .evaluation_criterion
          .grade_labels
          .find { |g| g['grade'] == grade }['label']

      I18n.t(
        'mailers.startup.feedback_as_email.body.grading_details_html',
        grade_icon: grade_icon,
        criteria_name: criteria_name,
        grade_label: grade_label,
        grade: grade,
        max_grade: te_grade.evaluation_criterion.max_grade
      ).html_safe
    }
  end
end
