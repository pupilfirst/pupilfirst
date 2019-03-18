module Schools
  module Courses
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context)
        super(view_context)
      end

      def react_props
        {
          courses: school_courses
        }
      end

      private

      def school_courses
        current_school.courses.map do |course|
          {
            id: course.id,
            name: course.name
          }
        end
      end
    end
  end
end
