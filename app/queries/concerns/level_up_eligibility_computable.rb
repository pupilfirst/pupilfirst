module LevelUpEligibilityComputable
  extend ActiveSupport::Concern

  def level_up_eligibility
    # A submissions does not affect eligibility to level up unless it's for a milestone target.
    return unless target.target_group.milestone?

    Students::LevelUpEligibilityService.new(student).eligibility
  end
end
