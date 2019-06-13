module AuthorizeStudent
  include ActiveSupport::Concern

  def authorized?
    # Has access to school
    return false unless current_school.present? && founder.present? && (course.school == current_school)

    # Founder has access to the course
    return false unless !course.ends_at&.past? && !startup.access_ends_at&.past?

    # Founder can complete the target
    target.level.number <= startup.level.number
  end

  def founder
    @founder ||= current_user.founders.joins(:level).where(levels: { course_id: course }).first
  end

  def startup
    @startup ||= founder.startup
  end

  def course
    @course ||= target.course
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def founders
    if target.founder_event?
      [founder]
    else
      founder.startup.founders
    end
  end
end
