class PlatformFeedbackPolicy < ApplicationPolicy
  def create?
    user&.founder&.startup&.level&.number&.positive?
  end
end
