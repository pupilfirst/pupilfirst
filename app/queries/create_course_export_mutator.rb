class CreateCourseExportMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :export_type, validates: { inclusion: CourseExport.valid_export_types }
  property :course_id, validates: { presence: { message: 'CourseIdBlank' } }
  property :tag_ids
  property :reviewed_only

  validate :require_valid_course
  validate :require_valid_tags

  def require_valid_course
    return if course.present?

    errors[:base] << 'Could not find a course with the given ID'
  end

  def require_valid_tags
    return if tag_ids.count == tags.count

    errors[:base] << 'Could not find tags with the given IDs'
  end

  def create_course_export
    CourseExport.transaction do
      tag_list = tags.present? ? tags.pluck(:name) : []

      export = CourseExport.create!(
        export_type: export_type,
        course: course,
        user: current_user,
        reviewed_only: !!reviewed_only,
        tag_list: tag_list,
      )

      # Queue a job to prepare the report.
      CourseExports::PrepareJob.perform_later(export)

      # Return the course export.
      export
    end
  end

  private

  def tags
    @tags ||= current_school.founder_tags.where(id: tag_ids)
  end

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end
end
