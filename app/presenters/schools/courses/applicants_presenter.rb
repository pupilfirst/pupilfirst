module Schools
  module Courses
    class ApplicantsPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course
        super(view_context)
      end

      def props
        { course_id: @course.id, tags: tags }
      end

      private

      def tags
        @tags ||= current_school.founder_tag_list
      end
    end
  end
end
