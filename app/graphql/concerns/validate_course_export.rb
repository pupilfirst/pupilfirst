module ValidateCourseExport
  extend ActiveSupport::Concern

  class RequireValidCourse < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      course = Course.find_by(id: value[:course_id])

      return if course.present?

      I18n.t("mutations.export_course_report.course_not_found_error")
    end
  end

  class RequireValidTags < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      course = Course.find_by(id: value[:course_id])
      current_school = course&.school
      tags = current_school.student_tags.where(id: value[:tag_ids])
      return if value[:tag_ids].count == tags.count
      I18n.t("mutations.export_course_report.tag_not_found_error")
    end
  end

  class RequireValidCohorts < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      course = Course.find_by(id: value[:course_id])
      cohorts = course.cohorts.where(id: value[:cohort_ids])
      return if value[:cohort_ids].count == cohorts.count
      I18n.t("mutations.export_course_report.cohorts_not_found_error")
    end
  end

  included do
    argument :course_id, GraphQL::Types::ID, required: true
    argument :export_type, Types::ExportType, required: true
    argument :tag_ids, [GraphQL::Types::ID], required: true
    argument :reviewed_only, GraphQL::Types::Boolean, required: true
    argument :include_inactive_students, GraphQL::Types::Boolean, required: true
    argument :cohort_ids, [GraphQL::Types::ID], required: true
    argument :include_user_standings, GraphQL::Types::Boolean, required: true

    validates RequireValidCourse => {}
    validates RequireValidTags => {}
    validates RequireValidCohorts => {}
  end
end
