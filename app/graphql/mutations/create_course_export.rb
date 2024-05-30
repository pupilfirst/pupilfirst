module Mutations
  class CreateCourseExport < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    include ValidateCourseExport

    description "Request a course export."

    field :course_export, Types::CourseExportType, null: true

    def create_course_export
      CourseExport.transaction do
        tag_list = tags.present? ? tags.pluck(:name) : []

        export =
          CourseExport.create!(
            export_type: @params[:export_type],
            course: course,
            user: current_user,
            reviewed_only: !!@params[:reviewed_only],
            include_inactive_students: @params[:include_inactive_students],
            tag_list: tag_list,
            include_user_standings: @params[:include_user_standings]
          )

        cohorts.map do |cohort|
          CourseExportsCohort.create!(cohort: cohort, course_export: export)
        end
        # Queue a job to prepare the report.
        CourseExports::PrepareJob.perform_later(export)

        export
      end
    end

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.processing"),
        I18n.t("mutations.export_course_report.success_notification")
      )

      { course_export: create_course_export }
    end

    def tags
      @tags ||= current_school.student_tags.where(id: @params[:tag_ids])
    end

    def cohorts
      @cohorts ||= course.cohorts.where(id: @params[:cohort_ids])
    end

    def resource_school
      current_school
    end

    def course
      @course ||= Course.find_by(id: @params[:course_id])
    end
  end
end
