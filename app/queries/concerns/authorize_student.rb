module AuthorizeStudent
  include ActiveSupport::Concern

  def authorized?
    return false if current_user.blank?

    # Has access to school
    return false unless course&.school == current_school && student.present?

    # Student has access to the course
    return false unless !student.cohort.ended?

    # Level must be accessible.
    return false unless LevelPolicy.new(pundit_user, target.level).accessible?

    target_can_be_completed?
  end

  # Students can complete a live target if they're non-reviewed, or if they've reached the target's level for reviewed targets.
  def target_can_be_completed?
    target.live? && target.evaluation_criteria.empty?
  end

  def student
    @student ||=
      current_user
        .students
        .joins(:cohort)
        .where(cohorts: { course_id: course })
        .first
  end

  def course
    @course ||= target&.course
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def students
    target.team_target? && student.team ? student.team.students : [student]
  end

  def ensure_submittability
    return if target_status == Targets::StatusService::STATUS_PENDING

    errors.add(
      :base,
      "Target status #{target_status.to_s.humanize}, You cannot submit the target"
    )
  end

  def target_status
    @target_status ||= Targets::StatusService.new(target, student).status
  end
end
