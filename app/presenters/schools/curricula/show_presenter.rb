module Schools
  module Curricula
    class ShowPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def evaluation_criteria
        @course.evaluation_criteria.select(:id, :name, :description)
      end

      def levels
        @course.levels.select(:id, :name, :description, :number)
      end

      def target_groups(level)
        level.target_groups.select(:id, :name, :description, :sort_index, :milestone)
      end

      def targets(target_group)
        target_group.targets.select(:id, :role, :title, :description, :target_action_type, :sort_index)
      end
    end
  end
end
