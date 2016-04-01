require_relative 'helper'

after 'development:startups' do
  super_startup = Startup.find_by(product_name: 'Super Product')
  avengers_startup = Startup.find_by(product_name: 'SuperHeroes')

  # generate the default joined SV.CO event for both startups
  super_startup.prepopulate_timeline!
  avengers_startup.prepopulate_timeline!

  VERIFIED = TimelineEvent::VERIFIED_STATUS_VERIFIED
  PENDING = TimelineEvent::VERIFIED_STATUS_PENDING
  NEEDS_IMPROVEMENT = TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT

  # Add a one-liner verified entry for avengers
  events_list = [
    [avengers_startup, 'one_liner', 'ironman@avengers.co', 'We came up with a new one-liner for avengers: Everyone creates the thing they fear.', VERIFIED]
  ]

  # Add a pending 'team-formed' pending entry for avengers
  events_list += [
    [avengers_startup, 'team_formed', 'ironman@avengers.co', 'We formed our team to fight the evil!', PENDING]
  ]

  # Add a 'new_product_deck' for avengers which needs improvement
  events_list += [
    [avengers_startup, 'new_product_deck', 'ironman@avengers.co', 'We have a new presentation about us!', NEEDS_IMPROVEMENT]
  ]

  # create all events in the events_list
  events_list.each do |startup, type_key, founder_email, description, verified_status|
    TimelineEvent.create!(
      startup: startup,
      timeline_event_type: TimelineEventType.find_by_key(type_key),
      founder: Founder.find_by_email(founder_email),
      event_on: Time.now,
      description: description,
      verified_status: verified_status,
      verified_at: (verified_status==VERIFIED ? Time.now : nil)
    )
  end
end
