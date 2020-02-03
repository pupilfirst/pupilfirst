# TODO: Replace all usage of FounderSpecHelper with new SubmissionsHelper.
#
# IMPORTANT: Use SubmissionsHelper instead of this module.
#
# Some helpers to deal with founders in specs.
module FounderSpecHelper
  # This 'completes' a target for a founder - both startup and founder role targets.
  def complete_target(founder, target, passed_at: Time.zone.now, grade: nil)
    submit_target(founder, target, passed: true, passed_at: passed_at, grade: grade)
  end

  def submit_target(founder, target, passed: false, passed_at: Time.zone.now, grade: nil)
    startup = founder.startup

    if target.individual_target?
      startup.founders.each do |startup_founder|
        create_timeline_event(startup_founder, target, passed: passed, passed_at: passed_at, grade: grade)
      end
    else
      create_timeline_event(founder, target, passed: passed, passed_at: passed_at, grade: grade)
    end
  end

  # This creates a timeline event for a target, attributed to supplied founder.
  def create_timeline_event(founder, target, passed: false, passed_at: nil, grade: nil)
    options = timeline_event_options(founder, passed, passed_at, target)

    FactoryBot.create(:timeline_event, options).tap do |te|
      # Add grades for passing submissions if evaluation criteria are present.
      if target.evaluation_criteria.present? && options[:passed_at].present?
        te.evaluation_criteria.each do |ec|
          create(
            :timeline_event_grade,
            timeline_event: te,
            grade: grade || rand(target.course.pass_grade..target.course.max_grade),
            evaluation_criterion: ec
          )
        end
      end
    end
  end

  private

  def timeline_event_options(founder, passed, passed_at, target)
    passed_at = if passed_at.present?
      passed_at
    else
      passed ? Time.zone.now : nil
    end

    {
      founders: [founder],
      target: target,
      latest: true,
      passed_at: passed_at
    }
  end
end
