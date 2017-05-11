require_relative 'helper'

after 'development:timeline_events', 'development:faculty' do
  event_needs_improvement = TimelineEvent.find_by(verified_status: TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT)
  mickey = Faculty.find_by(email: 'mickeymouse@example.com')

  StartupFeedback.create!(
    feedback: Faker::Lorem.paragraphs(2).join("\n\n"),
    reference_url: "http://sv.dev/startups/#{event_needs_improvement.startup.slug}#event-#{event_needs_improvement.id}",
    startup: event_needs_improvement.startup,
    faculty: mickey,
    activity_type: 'Feedback on presentation',
    attachment: File.open(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'mickey_mouse.jpg'))
  )
end
