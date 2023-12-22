after "development:timeline_events" do
  puts "Seeding startup feedback"

  # Make sure there is at least one submission with two feedback entries.
  timeline_event =
    TimelineEvent
      .joins(:startup_feedback)
      .group(:id)
      .having("count(startup_feedback.id) > 1")
      .first

  unless timeline_event
    TimelineEvent
      .joins(:startup_feedback)
      .first
      .startup_feedback
      .create!(
        feedback: "Some additional feedback sent later",
        faculty: Faculty.first,
        sent_at: Time.zone.now
      )
  end
end
