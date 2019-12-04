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
          evaluation_criteria: @course.evaluation_criteria.map { |ec| { id: ec.id, name: ec.name } }
        }
      end
    end
  end
end
