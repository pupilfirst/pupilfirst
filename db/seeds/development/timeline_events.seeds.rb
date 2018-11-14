require_relative 'helper'

after 'development:startups', 'development:target_groups', 'development:targets' do
  puts 'Seeding timeline_events'

  avengers_startup = Startup.find_by(product_name: 'SuperHeroes')

  status_verified = TimelineEvent::STATUS_VERIFIED
  status_pending = TimelineEvent::STATUS_PENDING
  status_needs_improvement = TimelineEvent::STATUS_NEEDS_IMPROVEMENT

  # Add a verified timeline event for avengers
  events_list = [
    [avengers_startup, 'ironman@example.org', 'We came up with a new one-liner for avengers: Everyone creates the thing they fear.', status_verified]
  ]

  # Add a pending timeline event pending entry for avengers
  events_list += [
    [avengers_startup, 'ironman@example.org', 'We formed our team to fight the evil!', status_pending]
  ]

  # Add a timeline event for avengers which needs improvement, and a pending 'improved' event.
  events_list += [
    [avengers_startup, 'ironman@example.org', 'We have a presentation about us!', status_needs_improvement],
    [avengers_startup, 'ironman@example.org', 'We an improved presentation. This time as an attachment!', status_pending]
  ]

  # create all events in the events_list
  events_list.each do |startup, founder_email, description, status|
    TimelineEvent.create!(
      startup: startup,
      founder: Founder.find_by(email: founder_email),
      event_on: Time.now,
      description: description,
      status: status,
      status_updated_at: (status == status_verified ? Time.now : nil)
    )
  end

  # Mark new product deck event as improvement of old one.
  old_event = avengers_startup.timeline_events.find_by(
    description: 'We have a presentation about us!',
    status: status_needs_improvement
  )

  avengers_startup.timeline_events.find_by(
    description: 'We an improved presentation. This time as an attachment!',
    status: status_pending
  ).update!(improvement_of: old_event)


  # Complete all Level 1 and Level 2 targets for 'Avengers' startup.
  [1, 2].each do |level_number|
    Target.joins(target_group: :level).where(levels: { number: level_number }).each do |target|
      score = [1.0, 1.5, 2.0, 2.5, 3.0].sample

      TimelineEvent.create!(
        startup: avengers_startup,
        target: target,
        founder: avengers_startup.team_lead,
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
    founder: ios_founder,
    event_on: Time.now,
    description: 'This is a seeded pending submission for the iOS startup',
    status: status_pending
  )
end
