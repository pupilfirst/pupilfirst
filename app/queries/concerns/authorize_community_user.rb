module AuthorizeCommunityUser
  include ActiveSupport::Concern

  def authorized_create?
    # Current user must exist, and the community in question must be in the 'current' school.
    return false unless current_user.present? && (community&.school == current_school)

    # Coach has access to all communities
    return true if current_coach.present?

    # User should have access to the community
    current_user.founders.includes(:course).where(courses: { id: community.courses }).any?
  end

  def authorized_update?
    authorized_create? && (creator == current_user || current_coach.present?)
  end

  def authorized_archive?
    if post.post_number != 1
      authorized_update?
    else
      authorized_create? && (((creator == current_user) && !topic.replies.live.exists?) || current_coach.present?)
    end
  end

  def current_coach
    current_user.faculty
  end
end
