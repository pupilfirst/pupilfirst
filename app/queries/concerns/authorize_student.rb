module AuthorizeStudent
  include ActiveSupport::Concern

  def authorized?
    return false if current_user.blank?

    # Has access to school
    return false unless course&.school == current_school && student.present?

    # Founder has access to the course
    return false unless !course.ends_at&.past? && !team.access_ends_at&.past?

    # Level must be accessible.
    return false unless LevelPolicy.new(pundit_user, target.level).accessible?

    target_can_be_completed?
  end

  # Students can complete a live target if they're non-reviewed, or if they've reached the target's level for reviewed targets.
  def target_can_be_completed?
    target.live? && (target.evaluation_criteria.empty? || target.level.number <= team.level.number)
  end

  def student
    @student ||= current_user.founders.joins(:level).where(levels: { course_id: course }).first
  end

  def team
    @team ||= student.startup
  end

  def course
    @course ||= target&.course
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def students
    if target.individual_target?
      [student]
    else
      student.startup.founders
    end
  end

  def ensure_submittability
    return if target_status == Targets::StatusService::STATUS_PENDING

    errors[:base] << "Target status #{target_status.to_s.humanize}, You cannot submit the target"
  end

  def target_status
    @target_status ||= Targets::StatusService.new(target, student).status
  end
end
