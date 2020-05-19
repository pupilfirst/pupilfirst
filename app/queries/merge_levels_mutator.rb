class MergeLevelsMutator < ApplicationQuery
  include AuthorizeAuthor

  property :delete_level_id, validates: { presence: true }
  property :merge_into_level_id, validates: { presence: true }

  validate :level_to_merge_into_must_exist

  def merge_levels
    Levels::MergeService.new(level_to_delete).merge_into(level_to_merge_into)
  end

  private

  def resource_school
    course&.school
  end

  def level_to_merge_into_must_exist
    return if level_to_merge_into.present?

    errors[:base] << 'Level to merge into could not be found'
  end

  def course
    @course = level_to_delete&.course
  end

  def level_to_delete
    @level_to_delete ||= Level.find_by(id: delete_level_id)
  end

  def level_to_merge_into
    @level_to_merge_into ||= course.levels.find_by(id: merge_into_level_id)
  end
end
