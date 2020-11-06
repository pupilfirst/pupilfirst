module AuthorizeCoach
  include ActiveSupport::Concern

  def authorized?
    # Needs a valid faculty profile
    return false if current_user&.faculty.blank?

    return false if course&.school != current_school

    current_user.faculty.courses.exists?(id: course)
  end
end
