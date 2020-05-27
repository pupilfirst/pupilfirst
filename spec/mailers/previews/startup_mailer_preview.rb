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
      faculty: Faculty.last,
      startup: Startup.last
    )

    StartupMailer.feedback_as_email(startup_feedback)
  end

  private

  def connect_request
    ConnectRequest.new(
      id: 1,
      connect_slot: connect_slot,
      startup: Startup.last,
      questions: Faker::Lorem.paragraphs(number: 2).join("\n\n"),
      status: ConnectRequest::STATUS_CONFIRMED,
      meeting_link: 'https://example.com/meeting_url'
    )
  end

  def connect_slot
    ConnectSlot.new(
      faculty: Faculty.first,
      slot_at: 2.days.from_now
    )
  end
end
