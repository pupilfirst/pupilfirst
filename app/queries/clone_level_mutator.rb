class CloneLevelMutator < ApplicationQuery
  include AuthorizeAuthor

  property :level_id, validates: { presence: true }
  property :clone_into_course_id, validates: { presence: true }

  validate :require_valid_school

  def clone_level
    ::Levels::CloneLevelJob.perform_later(level.id, target_course.id)
  end

  private

  def resource_school
    level.course.school
  end

  def target_course
    @target_course ||= Course.find(clone_into_course_id)
  end

  def level
    @level ||= Level.find(level_id)
  end

  def require_valid_school
    return if resource_school&.id == target_course&.school&.id

    errors[:base] << "Unable to copy level to another school"
  end
end
