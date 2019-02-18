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
          levels: levels,
          targetGroups: target_groups,
          targets: targets,
          authenticityToken: view.form_authenticity_token
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
            levelNumber: level.number,
            unlockOn: level.unlock_on
          }
        end
      end

      def target_groups
        @course.target_groups.map do |target_group|
          {
            id: target_group.id,
            name: target_group.name,
            levelId: target_group.level.id
          }
        end
      end

      def targets
        @course.targets.map do |target|
          {
            id: target.id,
            title: target.title,
            targetGroupId: target.target_group.id
          }
        end
      end
    end
  end
end
