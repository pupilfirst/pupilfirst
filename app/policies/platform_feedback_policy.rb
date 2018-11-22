class PlatformFeedbackPolicy < ApplicationPolicy
  def create?
    current_founder&.startup&.level&.number&.positive?
  end
end
