module ValidateCourseExport
  extend ActiveSupport::Concern

  class RequireValidCourse < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      course = Course.find_by(id: value[:course_id])
      return if course.present?
      errors[:base] << 'Could not find a course with the given ID'
    end
  end

  class RequireValidTags < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      course = Course.find_by(id: value[:course_id])
      current_school= course&.school
      tags ||= current_school.founder_tags.where(id: value[:tag_ids])
      return if value[:tag_ids].count == tags.count
      errors[:base] << 'Could not find tags with the given IDs'
    end
  end


  included do
    argument :course_id, GraphQL::Types::ID, required: true
    argument :export_type, Types::ExportType, required: true
    argument :tag_ids, [GraphQL::Types::ID], required: true
    argument :reviewed_only, GraphQL::Types::Boolean, required: true
    argument :include_inactive, GraphQL::Types::Boolean, required: true

    validates RequireValidCourse => {}
    validates RequireValidTags => {}
  end
end
