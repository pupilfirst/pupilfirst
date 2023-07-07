module Schools
  module Courses
    class AssignmentsPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course

        super(view_context)
      end

      def last_index
        @last_index ||= milestone_targets.size - 1
      end

      def milestone_targets
        @milestone_targets ||=
          @course.targets.order(milestone_number: :asc).milestones
      end

      def link(target_id, direction = "down")
        "/school/courses/#{@course.id}/assignments/#{target_id}?direction=#{direction}"
      end
    end
  end
end
