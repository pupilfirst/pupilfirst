class UnarchiveCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id, validates: { presence: true }

  def unarchive_course
    return if course.blank? || course.live?

    content_block.update!(archived_at: nil)
  end

  private

  def resource_school
    course.school
  end

  def course
    Course.find_by(id: id)
  end
end
