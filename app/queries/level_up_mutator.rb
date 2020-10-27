class LevelUpMutator < ApplicationQuery
  property :course_id, validates: { presence: true }

  validate :must_be_eligible

  def execute
    level_up
  end

  private

  def must_be_eligible
    return if level_up_eligibility_service.eligible?

    errors[:base] << level_up_eligibility_service.eligibility
  end

  def level_up_eligibility_service
    @level_up_eligibility_service ||= Students::LevelUpEligibilityService.new(student)
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def team
    @team ||= student.startup
  end

  def student
    @student ||= current_user.founders.joins(:level).find_by(levels: { course_id: course_id })
  end

  def authorized?
    course&.school == current_school && student.present?
  end

  def level_up
    next_level = course.levels.find_by(number: team.level.number + 1)
    team.update!(level: next_level)
  end
end
