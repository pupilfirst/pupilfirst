# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback, include_grades)
    @startup_feedback = startup_feedback

    @students =
      @startup_feedback.timeline_event.students.map(&:fullname).join(", ")

    @grading_details = grading_details(startup_feedback, include_grades)

    send_to =
      startup_feedback.timeline_event.students.map do |e|
        "#{e.fullname} <#{e.email}>"
      end

    @school = startup_feedback.timeline_event.students.first.school

    subject =
      I18n.t(
        "mailers.startup.feedback_as_email.subject",
        coach_name: startup_feedback.faculty.name
      )
    simple_mail(send_to, subject)
  end

  def grading_details(startup_feedback, include_grades)
    return unless include_grades

    timeline_event_grades =
      startup_feedback.timeline_event.timeline_event_grades.includes(
        :evaluation_criterion
      )

    timeline_event_grades.map do |te_grade|
      criteria_name = te_grade.evaluation_criterion.name
      grade = te_grade.grade

      grade_label =
        te_grade.evaluation_criterion.grade_labels.find do |g|
          g["grade"] == grade
        end[
          "label"
        ]

      I18n.t(
        "mailers.startup.feedback_as_email.body.grading_details_html",
        criteria_name: criteria_name,
        grade_label: grade_label,
        grade: grade,
        max_grade: te_grade.evaluation_criterion.max_grade
      ).html_safe
    end
  end

  def comment_on_submission(submission, comment, user)
    @submission = submission
    @student_names = submission.students.map(&:fullname).join(", ")
    @comment = comment
    @commenter = user
    @school = user.school

    send_to = submission.students.map { |e| "#{e.fullname} <#{e.email}>" }

    simple_mail(
      send_to,
      I18n.t(
        "mailers.startup.comment_on_submission.subject",
        school_name: @school.name
      )
    )
  end
end
