module Schools
  module Curricula
    class ShowPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def react_props
        {
          course: course_data,
          evaluationCriteria: evaluation_criteria,
          levels: levels
        }
      end

      def course_data
        {
          id: @course.id,
          name: @course.name
        }
      end

      def evaluation_criteria
        @course.evaluation_criteria.map do |criteria|
          {
            id: criteria.id,
            name: criteria.name
          }
        end
      end

      def levels
        @course.levels.map do |level|
          {
            id: level.id,
            name: level.name,
            targetGroups: target_groups(level)
          }
        end
      end

      def target_groups(level)
        level.target_groups.map do |target_group|
          {
            id: target_group.id,
            name: target_group.name,
            targets: targets(target_group)
          }
        end
      end

      def targets(target_group)
        target_group.targets.map do |target|
          {
            id: target.id,
            title: target.title
          }
        end
      end
    end
  end
end
