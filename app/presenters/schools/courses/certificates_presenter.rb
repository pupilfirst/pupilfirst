module Schools
  module Courses
    class CertificatesPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course

        super(view_context)
      end

      def props
        {
          course: course_details,
        }
      end

      private

      def course_details
        {
          id: @course.id,
          name: @course.name
        }
      end
    end
  end
end
