module Schools
  module Courses
    class ExportsPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course

        super(view_context)
      end

      def props
        {
          tags: tag_details,
          course: course_details,
          exports: course_export_details,
          cohorts: cohort_details
        }
      end

      def course_exports
        @course_exports ||=
          @course
            .course_exports
            .order(created_at: :DESC)
            .includes(:cohorts)
            .includes(:tags)
            .with_attached_file
            .page(params[:page])
            .per(10)
      end

      private

      def tag_details
        @course.school.student_tags.as_json(only: %i[id name])
      end

      def course_details
        { id: @course.id }
      end

      def course_export_details
        course_exports.map do |export|
          file =
            if export.file.attached?
              {
                path: view.rails_public_blob_url(export.file),
                created_at: export.file.created_at
              }
            end

          {
            id: export.id,
            created_at: export.created_at,
            file: file,
            export_type: export.export_type,
            tags: export.tags.collect(&:name),
            reviewed_only: export.reviewed_only,
            includeInactiveStudents: export.include_inactive_students,
            cohort_ids: export.course_exports_cohorts.pluck(:cohort_id),
            includeUserStandings: export.include_user_standings
          }
        end
      end

      def cohort_details
        @course.cohorts.as_json
      end
    end
  end
end
