module AuthorizeCoach
  include ActiveSupport::Concern

  def authorized?
    # Needs a valid faculty profile
    return false if current_user&.faculty.blank?

    return false if course.blank?

    course.in? current_user.faculty.courses_with_dashboard
  end
end
