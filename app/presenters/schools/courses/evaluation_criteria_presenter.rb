module Schools
  module Courses
    class EvaluationCriteriaPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course
        super(view_context)
      end

      def page_title
        "#{@course.name} | #{current_school.name}"
      end

      private

      def props
        {
          course_id: @course.id
        }
      end
    end
  end
end
