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
      status_updated_at: (status == status_verified ? Time.now : nil)
    )
  end

  # Complete all Level 1 and Level 2 targets for 'Avengers' startup on their first iteration.
  [1, 2].each do |level_number|
    Target.joins(target_group: :level).where(levels: { number: level_number }).each do |target|
      grade = [TimelineEvent::GRADE_GOOD, TimelineEvent::GRADE_GREAT, TimelineEvent::GRADE_WOW].sample

      TimelineEvent.create!(
        startup: avengers_startup,
        target: target,
        timeline_event_type: target.timeline_event_type,
        founder: avengers_startup.team_lead,
        event_on: Time.now,
        description: Faker::Lorem.paragraph,
        status: status_verified,
        status_updated_at: Time.now,
        grade: grade
      )
    end
  end
end
