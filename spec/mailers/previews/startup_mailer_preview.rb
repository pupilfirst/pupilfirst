class StartupMailerPreview < ActionMailer::Preview
  def feedback_as_email
    startup_feedback = StartupFeedback.new(
      id: 1,
      feedback: "This is the feedback text.\nIt is multi-line.",
      timeline_event: TimelineEvent.new(
        id: 2,
        founders: [Founder.first],
        target: Target.new(id: 1, title: 'Super Cool Target')
      ),
      faculty: Faculty.new(
        name: 'C V Raman'
      ),
      startup: Startup.first
    )

    StartupMailer.feedback_as_email(startup_feedback)
  end

  def connect_request_confirmed
    connect_request = ConnectRequest.first

    StartupMailer.connect_request_confirmed(connect_request)
  end
end
