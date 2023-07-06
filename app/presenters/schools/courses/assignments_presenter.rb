module Schools
  module Courses
    class AssignmentsPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course

        super(view_context)
      end

      def target_count
        @target_count ||= milestone_targets.size
      end

      def milestone_targets
        @milestone_targets ||=
          @course.targets.order(milestone_number: :asc).milestones
      end
    end
  end
end
