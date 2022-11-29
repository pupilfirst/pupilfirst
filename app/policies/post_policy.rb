class PostPolicy < ApplicationPolicy
  def versions?
    current_school_admin.present? ||
      (current_coach.present? && !current_coach.exited?)
  end
end
