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
          evaluation_criteria: evaluation_criteria,
          levels: levels,
          target_groups: target_groups,
          targets: targets,
          has_vimeo_access_token: vimeo_access_token?,
          vimeo_plan: vimeo_plan,
          markdown_curriculum_editor_max_length:
            markdown_curriculum_editor_max_length
        }
      end

      def course_data
        { id: @course.id }
      end

      def evaluation_criteria
        @course.evaluation_criteria.map do |criteria|
          { id: criteria.id, name: criteria.display_name }
        end
      end

      def levels
        @course.levels.map do |level|
          {
            id: level.id,
            name: level.name,
            number: level.number,
            unlock_at: level.unlock_at
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
            sort_index: target_group.sort_index,
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
            sort_index: target.sort_index,
            visibility: target.visibility,
            milestone: target.milestone
          }
        end
      end

      def vimeo_access_token?
        if instance_variable_defined?(:@vimeo_access_token)
          return @vimeo_access_token
        end

        @vimeo_access_token =
          Schools::Configuration::Vimeo.new(@course.school).configured? ||
            Rails.application.secrets.vimeo_access_token.present?
      end

      def vimeo_plan
        return unless vimeo_access_token?

        Schools::Configuration::Vimeo
          .new(@course.school)
          .account_type
          .presence || Rails.application.secrets.vimeo_account_type
      end

      def markdown_curriculum_editor_max_length
        Rails.application.secrets.markdown_curriculum_editor_max_length
      end
    end
  end
end
