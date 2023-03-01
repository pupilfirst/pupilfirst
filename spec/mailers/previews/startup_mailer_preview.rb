class StartupMailerPreview < ActionMailer::Preview
  def feedback_as_email_with_grade
    last_timeline_event_grade = TimelineEventGrade.last
    startup_feedback = StartupFeedback.where(timeline_event_id: last_timeline_event_grade.timeline_event_id).last

    StartupMailer.feedback_as_email(startup_feedback, true)
  end

  def feedback_as_email
    startup_feedback = StartupFeedback.last

    StartupMailer.feedback_as_email(startup_feedback, false)
  end
end
