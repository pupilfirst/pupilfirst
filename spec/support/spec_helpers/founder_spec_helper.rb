# Some helpers to deal with founders in specs.
module FounderSpecHelper
  # This 'completes' a target for a founder - both startup and founder role targets.
  def complete_target(founder, target)
    submit_target(founder, target, verified: true)
  end

  def submit_target(founder, target, verified: false)
    startup = founder.startup

    if target.founder_role?
      startup.founders.each do |startup_founder|
        create_timeline_event(startup_founder, target, verified: verified)
      end
    else
      create_timeline_event(founder, target, verified: verified)
    end
  end

  # This creates a timeline event for a target, attributed to supplied founder.
  def create_timeline_event(founder, target, verified: false)
    traits = %i[timeline_event]
    traits += %i[verified] if verified

    FactoryBot.create(
      *traits,
      founder: founder,
      target: target,
      startup: founder.startup,
      timeline_event_type: target.timeline_event_type
    )
  end
end
