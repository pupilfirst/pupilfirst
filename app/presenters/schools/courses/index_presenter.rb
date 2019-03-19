module Schools
  module Courses
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context)
        super(view_context)
      end

      def react_props
        {
          courses: school_courses,
          authenticityToken: view.form_authenticity_token
        }
      end

      private

      def school_courses
        current_school.courses.map do |course|
          {
            id: course.id,
            name: course.name,
            maxGrage: course.max_grade,
            passGrade: course.pass_grade,
            gradeLabels: course.grade_labels,
            endsAt: course.ends_at
          }
        end
      end
    end
  end
end
