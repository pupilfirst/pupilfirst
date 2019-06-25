class PlatformFeedbackPolicy < ApplicationPolicy
  def create?
    # marked for removal
    user&.founders&.first&.startup&.level&.number&.positive?
  end
end
