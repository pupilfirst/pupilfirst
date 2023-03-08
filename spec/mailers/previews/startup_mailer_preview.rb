class StartupMailerPreview < ActionMailer::Preview
  def feedback_as_email_with_grade
    startup_feedback = TimelineEventGrade.last.timeline_event.startup_feedback.first

    StartupMailer.feedback_as_email(startup_feedback, true)
  end

  def feedback_as_email
    startup_feedback = StartupFeedback.last

    StartupMailer.feedback_as_email(startup_feedback, false)
  end
end
