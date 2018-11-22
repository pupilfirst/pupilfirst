# Some helpers to deal with founders in specs.
module FounderSpecHelper
  # This 'completes' a target for a founder - both startup and founder role targets.
  def complete_target(founder, target)
    submit_target(founder, target, passed: true)
  end

  def submit_target(founder, target, passed: false)
    startup = founder.startup

    if target.founder_role?
      startup.founders.each do |startup_founder|
        create_timeline_event(startup_founder, target, passed: passed)
      end
    else
      create_timeline_event(founder, target, passed: passed)
    end
  end

  # This creates a timeline event for a target, attributed to supplied founder.
  def create_timeline_event(founder, target, passed: false)
    traits = %i[timeline_event]
    traits += %i[passed] if passed

    FactoryBot.create(
      *traits,
      founder: founder,
      target: target,
      startup: founder.startup
    )
  end
end
