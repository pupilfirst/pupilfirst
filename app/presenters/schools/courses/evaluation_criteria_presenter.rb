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
          course_id: @course.id,
          evaluation_criteria: evaluation_criteria
        }
      end

      def evaluation_criteria
        @course.evaluation_criteria.map do |ec|
          {
            id: ec.id,
            name: ec.name,
            max_grade: ec.max_grade,
            pass_grade: ec.pass_grade,
            grade_labels: ec.grade_labels
          }
        end
      end
    end
  end
end
