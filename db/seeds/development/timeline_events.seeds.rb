require_relative 'helper'

after 'development:startups', 'development:target_groups', 'development:targets' do
  puts 'Seeding timeline_events'

  avengers_startup = Startup.find_by(product_name: 'SuperHeroes')

  status_verified = TimelineEvent::STATUS_VERIFIED
  status_pending = TimelineEvent::STATUS_PENDING
  status_needs_improvement = TimelineEvent::STATUS_NEEDS_IMPROVEMENT

  # Add a one-liner verified entry for avengers
  events_list = [
    [avengers_startup, 'one_liner', 'ironman@avengers.co', 'We came up with a new one-liner for avengers: Everyone creates the thing they fear.', status_verified]
  ]

  # Add a pending 'team-formed' pending entry for avengers
  events_list += [
    [avengers_startup, 'team_formed', 'ironman@avengers.co', 'We formed our team to fight the evil!', status_pending]
  ]

  # Add a 'new_product_deck' for avengers which needs improvement
  events_list += [
    [avengers_startup, 'new_product_deck', 'ironman@avengers.co', 'We have a new presentation about us!', status_needs_improvement]
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
      verified_at: (status == status_verified ? Time.now : nil)
    )
  end

  # Complete a Level 2 milestone targets for SuperHeroes.
  level_2 = Level.find_by(number: 2)

  TargetGroup.find_by(level: level_2, milestone: true).targets.each_with_index do |target, index|
    grade = [TimelineEvent::GRADE_GOOD, TimelineEvent::GRADE_GREAT, TimelineEvent::GRADE_WOW][index]

    TimelineEvent.create!(
      startup: avengers_startup,
      target: target,
      timeline_event_type: target.timeline_event_type,
      founder: avengers_startup.admin,
      event_on: Time.now,
      description: Faker::Lorem.paragraph,
      status: status_verified,
      verified_at: Time.now,
      grade: grade
    )
  end
end
