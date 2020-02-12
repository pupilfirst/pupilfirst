module Schools
  module Courses
    class CurriculumPresenter < ApplicationPresenter
      include RoutesResolvable

      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def props
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
          id: @course.id
        }
      end

      def evaluation_criteria
        @course.evaluation_criteria.map do |criteria|
          {
            id: criteria.id,
            name: criteria.display_name
          }
        end
      end

      def levels
        @course.levels.map do |level|
          {
            id: level.id,
            name: level.name,
            number: level.number,
            unlockOn: level.unlock_on
          }
        end
      end

      def target_groups
        @course.target_groups.map do |target_group|
          {
            id: target_group.id,
            name: target_group.name,
            description: target_group.description,
            level_id: target_group.level_id,
            milestone: target_group.milestone,
            sortIndex: target_group.sort_index,
            archived: target_group.archived
          }
        end
      end

      def targets
        @course.targets.map do |target|
          {
            id: target.id,
            target_group_id: target.target_group_id,
            title: target.title,
            sortIndex: target.sort_index,
            visibility: target.visibility
          }
        end
      end
    end
  end
end
