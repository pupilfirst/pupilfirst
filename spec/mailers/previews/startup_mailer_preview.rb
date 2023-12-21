class StartupMailerPreview < ActionMailer::Preview
  def feedback_as_email_with_grade
    startup_feedback =
      TimelineEventGrade.last.timeline_event.startup_feedback.first

    StartupMailer.feedback_as_email(startup_feedback, true)
  end

  def feedback_as_email
    timeline_event = TimelineEventGrade.last.timeline_event

    startup_feedback =
      StartupFeedback.create!(
        timeline_event: timeline_event,
        faculty: timeline_event.startup_feedback.first.faculty,
        feedback: "This is additional feedback"
      )

    StartupMailer.feedback_as_email(startup_feedback, false)
  end

  def feedback_as_email_when_submission_is_rejected
    startup_feedback =
      TimelineEvent
        .where
        .missing(:timeline_event_grades)
        .first
        .startup_feedback
        .first

    StartupMailer.feedback_as_email(startup_feedback, false)
  end

  def feedback_as_email_for_form_response
    startup_feedback =
      Assignment
        .includes(:evaluation_criteria, :quiz)
        .where(evaluation_criteria: { id: nil }, quizzes: { id: nil })
        .first
        .timeline_events
        .first
        .startup_feedback
        .first

    StartupMailer.feedback_as_email(startup_feedback, false)
  end
end
