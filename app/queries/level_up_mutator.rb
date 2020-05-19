class LevelUpMutator < ApplicationQuery
  property :course_id, validates: { presence: true }

  validate :must_have_next_level
  validate :must_be_eligible

  def execute
    level_up
  end

  private

  def must_have_next_level
    return if next_level.present?

    errors[:base] << 'Maximum level reached - cannot level up.'
  end

  def must_be_eligible
    return if level_up_eligibility_service.eligible?

    errors[:base] << level_up_eligibility_service.eligibility
  end

  def level_up_eligibility_service
    @level_up_eligibility_service ||= Startups::LevelUpEligibilityService.new(startup, founder)
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def startup
    @startup ||= founder.startup
  end

  def founder
    @founder ||= current_user.founders.joins(:level).find_by(levels: { course_id: course_id })
  end

  def authorized?
    course&.school == current_school && founder.present?
  end

  def next_level
    @next_level ||= course.levels.find_by(number: startup.level.number + 1)
  end

  def level_up
    startup.update!(level: next_level)
  end
end
