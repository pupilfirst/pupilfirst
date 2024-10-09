class StartupMailerPreview < ActionMailer::Preview
  def feedback_as_email_with_grade
    startup_feedback =
      TimelineEventGrade.last.timeline_event.startup_feedback.first

    StartupMailer.feedback_as_email(startup_feedback, true)
  end

  def additional_feedback_as_email
    timeline_event =
      TimelineEvent
        .joins(:startup_feedback)
        .group(:id)
        .having("count(startup_feedback.id) > 1")
        .first

    startup_feedback = timeline_event.startup_feedback.last

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

  def comment_on_submission
    submission = Assignment.where(discussion: true).first.timeline_events.first
    comment = submission.submission_comments.first
    user = User.first

    StartupMailer.comment_on_submission(submission, comment, user)
  end
end
