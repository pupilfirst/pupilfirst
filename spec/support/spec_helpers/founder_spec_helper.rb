# Some helpers to deal with founders in specs.
module FounderSpecHelper
  # This 'completes' a target for a founder - both startup and founder role targets.
  def complete_target(founder, target)
    startup = founder.startup

    if target.founder_role?
      startup.founders.each do |startup_founder|
        create_verified_timeline_event(startup_founder, target)
      end
    else
      create_verified_timeline_event(founder, target)
    end
  end

  # This creates a verified timeline event for a target, attributed to supplied founder.
  def create_verified_timeline_event(founder, target)
    FactoryBot.create(
      :timeline_event,
      :verified,
      founder: founder,
      target: target,
      startup: founder.startup,
      timeline_event_type: target.timeline_event_type
    )
  end
end
