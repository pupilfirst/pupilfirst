class StartupMailerPreview < ActionMailer::Preview
  def feedback_as_email_with_grade
    startup_feedback =
      StartupFeedback.new(
        id: 1,
        feedback: "This is the feedback text.\n\nIt is multi-line.",
        timeline_event:
          TimelineEvent.new(
            id: 2,
            founders: [Founder.first],
            target: Target.new(id: 1, title: 'Super Cool Target')
          ),
        faculty: Faculty.last
      )

      grading_details = [
        {
          name: "Idea",
          max_grade: 4,
          pass_grade: 2,
          grade_label: "Rejected",
          grade: 1,
          status: "\u274c"
        },
        {
          name: "Code Quality",
          max_grade: 2,
          pass_grade: 2,
          grade_label: "Meets Expectations",
          grade: 2,
          status: "\u2705"
        },
      ]

    StartupMailer.feedback_as_email(startup_feedback, grading_details)
  end

  def feedback_as_email
    startup_feedback =
      StartupFeedback.new(
        id: 1,
        feedback: "This is the feedback text.\n\nIt is multi-line.",
        timeline_event:
          TimelineEvent.new(
            id: 2,
            founders: [Founder.first],
            target: Target.new(id: 1, title: 'Super Cool Target')
          ),
        faculty: Faculty.last
      )

    StartupMailer.feedback_as_email(startup_feedback, nil)
  end
end
