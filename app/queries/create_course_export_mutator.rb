class CreateCourseExportMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  attr_accessor :course_id
  attr_accessor :tag_ids

  validates :course_id, presence: { message: 'CourseIdBlank' }

  validate :require_valid_course
  validate :require_valid_tags

  def require_valid_course
    return if course.present?

    errors[:base] << 'InvalidCourseId'
  end

  def require_valid_tags
    return if tag_ids.count == tags.count

    errors[:base] << 'InvalidTagsIds'
  end

  def create_course_export
    CourseExport.transaction do
      export = CourseExport.new(course: course, user: current_user)
      tag_names = tags.pluck(:name)
      export.tag_list.add(*tag_names)
      export.save!

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

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
