class StartupPolicy < ApplicationPolicy
  def level_up?
    if record.level.number.positive?
      # If level 1 or above, user must be able to update to level up.
      # User's startup must be 'this' one.

      return false if current_founder.blank?

      return false unless current_founder.startup == record

      # Founder's subscription must be active, and he must not have exited.
      current_founder.subscription_active? && !current_founder.exited?
    end
    Startups::LevelUpEligibilityService.new(record, current_founder).eligible?
  end

  def billing?
    # Only startups in courses that are not sponsored needs a billing page.
    record.level.number.positive? && !record.level.course.sponsored?
  end
end
