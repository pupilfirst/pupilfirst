module AuthorizeFounder
  include ActiveSupport::Concern

  def authorized?
    # Has access to school
    return false unless current_school.present? && founder.present? && (course.school == current_school)

    # Founder has access to the course
    return false unless !course.ends_at&.past? && !startup.access_ends_at&.past?

    # Founder can complete the target
    target.level.number <= startup.level.number
  end
end
