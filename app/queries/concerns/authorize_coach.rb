module AuthorizeCoach
  include ActiveSupport::Concern

  def authorized?
    # Needs a valid faculty profile
    return false if current_user&.faculty.blank?

    return false if course.blank?

    current_user.faculty.reviewable_courses.where(id: course).exists?
  end
end
