class ArchiveCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id, validates: { presence: true }

  def archive_course
    return if course.blank? || course.archived?

    course.update!(archived_at: Time.zone.now, ends_at: course.ends_at.presence || Time.zone.now)

    course.startups.where(access_ends_at: nil).update_all(access_ends_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def resource_school
    course.school
  end

  def course
    Course.find_by(id: id)
  end
end
