module AuthorizeCommunityUser
  include ActiveSupport::Concern

  def authorized_create?
    # Can't like at PupilFirst, current user must exist, Can only like answers in the same school.
    return false unless current_school.present? && current_user.present? && (community&.school == current_school)

    # Coach has access to all communities
    return true if current_coach.present?

    # User should have access to the community
    current_user.founders.includes(:course).where(courses: { id: community.courses }).any?
  end

  def authorized_update?
    authorized_create? && (creator == current_user || current_coach.present?)
  end
end
