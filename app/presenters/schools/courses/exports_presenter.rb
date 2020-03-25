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
          exports: course_export_details
        }
      end

      private

      def tag_details
        @course.school.founder_tags.as_json(only: %i[id name])
      end

      def course_details
        {
          id: @course.id
        }
      end

      def course_export_details
        course_exports.map do |export|
          file = if export.file.attached?
            {
              path: view.rails_blob_path(export.file, only_path: true),
              created_at: export.file.created_at
            }
          end

          {
            id: export.id,
            created_at: export.created_at,
            file: file,
            export_type: export.export_type,
            tags: export.tags.collect(&:name),
            reviewed_only: export.reviewed_only
          }
        end
      end

      def course_exports
        @course_exports ||= @course.course_exports.order(created_at: :DESC).includes(:tags).with_attached_file.limit(50).load
      end
    end
  end
end
