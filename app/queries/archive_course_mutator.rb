class ArchiveCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id, validates: { presence: true }

  def archive_course
    return if course.blank? || course.archived?

    course.update!(archived_at: Time.zone.now)
  end

  private

  def resource_school
    course.school
  end

  def course
    Course.find_by(id: id)
  end
end
