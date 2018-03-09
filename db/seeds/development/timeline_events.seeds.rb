require_relative 'helper'

after 'development:startups', 'development:target_groups', 'development:targets' do
  puts 'Seeding timeline_events'

  avengers_startup = Startup.find_by(product_name: 'SuperHeroes')

  status_verified = TimelineEvent::STATUS_VERIFIED
  status_pending = TimelineEvent::STATUS_PENDING
  status_needs_improvement = TimelineEvent::STATUS_NEEDS_IMPROVEMENT

  # Add a one-liner verified entry for avengers
  events_list = [
    [avengers_startup, 'one_liner', 'ironman@example.org', 'We came up with a new one-liner for avengers: Everyone creates the thing they fear.', status_verified]
  ]

  # Add a pending 'team-formed' pending entry for avengers
  events_list += [
    [avengers_startup, 'team_formed', 'ironman@example.org', 'We formed our team to fight the evil!', status_pending]
  ]

  # Add a 'new_product_deck' for avengers which needs improvement, and a pending 'improved' event.
  events_list += [
    [avengers_startup, 'new_product_deck', 'ironman@example.org', 'We have a presentation about us!', status_needs_improvement],
    [avengers_startup, 'new_product_deck', 'ironman@example.org', 'We an improved presentation. This time as an attachment!', status_pending]
  ]

  # create all events in the events_list
  events_list.each do |startup, type_key, founder_email, description, status|
    TimelineEvent.create!(
      startup: startup,
      timeline_event_type: TimelineEventType.find_by(key: type_key),
      founder: Founder.find_by(email: founder_email),
      event_on: Time.now,
      description: description,
      status: status,
      status_updated_at: (status == status_verified ? Time.now : nil)
    )
  end

  # Mark new product deck event as improvement of old one.
  old_event = avengers_startup.timeline_events.find_by(
    timeline_event_type: TimelineEventType.find_by(key: 'new_product_deck'),
    status: status_needs_improvement
  )

  avengers_startup.timeline_events.find_by(
    timeline_event_type: TimelineEventType.find_by(key: 'new_product_deck'),
    status: status_pending
  ).update!(improvement_of: old_event)


  # Complete all Level 1 and Level 2 targets for 'Avengers' startup.
  [1, 2].each do |level_number|
    Target.joins(target_group: :level).where(levels: { number: level_number }).each do |target|
      score = [1.0, 1.5, 2.0, 2.5, 3.0].sample

      TimelineEvent.create!(
        startup: avengers_startup,
        target: target,
        timeline_event_type: target.timeline_event_type,
        founder: avengers_startup.team_lead,
        event_on: Time.now,
        description: Faker::Lorem.paragraph,
        status: status_verified,
        status_updated_at: Time.now,
        score: score
      )
    end
  end
end
