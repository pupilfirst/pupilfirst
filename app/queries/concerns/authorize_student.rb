module AuthorizeStudent
  include ActiveSupport::Concern

  def authorized?
    # Has access to school
    return false unless course&.school == current_school && founder.present?

    # Founder has access to the course
    return false unless !course.ends_at&.past? && !startup.access_ends_at&.past?

    # Level must be accessible.
    return false unless LevelPolicy.new(pundit_user, target.level).accessible?

    target_can_be_completed?
  end

  # Students can complete a live target if they're non-reviewed, or if they've reached the target's level for reviewed targets.
  def target_can_be_completed?
    target.live? && (target.evaluation_criteria.empty? || target.level.number <= startup.level.number)
  end

  def founder
    @founder ||= current_user.founders.joins(:level).where(levels: { course_id: course }).first
  end

  def startup
    @startup ||= founder.startup
  end

  def course
    @course ||= target&.course
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def founders
    if target.individual_target?
      [founder]
    else
      founder.startup.founders
    end
  end

  def ensure_submittability
    return if target_status == Targets::StatusService::STATUS_PENDING

    errors[:base] << "Target status #{target_status.to_s.humanize}, You cannot submit the target"
  end

  def target_status
    @target_status ||= Targets::StatusService.new(target, founder).status
  end
end
