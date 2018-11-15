require_relative 'helper'

after 'development:founders', 'development:targets', 'development:timeline_event_types' do
  puts 'Seeding timeline_events'

  avengers = Startup.find_by(product_name: 'The Avengers')

  status_verified = TimelineEvent::STATUS_VERIFIED
  status_pending = TimelineEvent::STATUS_PENDING
  status_needs_improvement = TimelineEvent::STATUS_NEEDS_IMPROVEMENT

  # Add a submission for 'The Avengers' which needs improvement, and a pending 'improved' event.
  avenger_events = [
    ['new_product_deck', 'ironman@example.org', 'We have a presentation about us!', status_needs_improvement],
    ['new_product_deck', 'ironman@example.org', 'We an improved presentation.', status_pending]
  ]

  avenger_target = avengers.school.targets.live.first

  # Create all events for 'The Avenger'
  avenger_events.each do |type_key, founder_email, description, status|
    TimelineEvent.create!(
      startup: avengers,
      timeline_event_type: TimelineEventType.find_by(key: type_key),
      founder: Founder.find_by(email: founder_email),
      event_on: Time.now,
      description: description,
      status: status,
      target: avenger_target
    )
  end

  # Mark new product deck event as improvement of old one.
  old_event = avengers.timeline_events.find_by(
    target: avenger_target,
    status: status_needs_improvement
  )

  avengers.timeline_events.find_by(
    target: avenger_target,
    status: status_pending
  ).update!(improvement_of: old_event)

  # Complete all Level 1 and Level 2 targets for 'The Avengers'.
  [1, 2].each do |level_number|
    Target.joins(target_group: :level).where(levels: { number: level_number, school_id: avengers.school.id }).each do |target|
      score = [1.0, 1.5, 2.0, 2.5, 3.0].sample

      TimelineEvent.create!(
        startup: avengers,
        target: target,
        timeline_event_type: target.timeline_event_type,
        founder: avengers.team_lead,
        event_on: Time.now,
        description: Faker::Lorem.paragraph,
        status: status_verified,
        status_updated_at: Time.now,
        score: score
      )
    end
  end

  # Create a pending timeline event in iOS startup.
  ios_founder = Founder.with_email('ios@example.org')
  ios_startup = ios_founder.startup

  TimelineEvent.create!(
    startup: ios_startup,
    timeline_event_type: TimelineEventType.find_by(key: 'general_submission'),
    founder: ios_founder,
    event_on: Time.now,
    description: 'This is a seeded pending submission for the iOS startup',
    status: status_pending,
    target: ios_startup.school.targets.live.first
  )
end
