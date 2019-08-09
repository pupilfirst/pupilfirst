module Schools
  module Courses
    class ExportsPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course

        super(view_context)
      end

      def props
        {
          course: course_details,
          exports: course_export_details
        }
      end

      private

      def course_details
        {
          id: @course.id,
          name: @course.name
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
            username: user.name,
            created_at: export.created_at,
            file: file
          }
        end
      end

      def course_exports
        @course_exports ||= @course.course_exports.order(created_at: :DESC).with_attached_file.includes(:user).limit(50).load
      end
    end
  end
end
