module Schools
  module Targets
    class CreateOrUpdateForm < Reform::Form
      property :role, validates: { presence: true }
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :visibility, validates: { presence: true }
      property :description
      property :target_action_type
      property :target_group_id, validates: { presence: true }
      property :sort_index
      property :youtube_video_id
      property :resource_ids
      property :prerequisite_target_ids
      property :evaluation_criterion_ids
      property :quiz
      property :link_to_complete, validates: { url: true, allow_blank: true }
      property :archived
      property :completion_instructions, validates: { presence: true, length: { maximum: 250 }, allow_blank: true }

      validate :target_group_exists
      validate :only_one_method_of_completion

      def target_group_exists
        errors[:base] << 'Invalid Target Group id' if target_group.blank?
      end

      def only_one_method_of_completion
        completion_criteria = [evaluation_criterion_ids.present?, link_to_complete.present?, quiz.present?]

        return if completion_criteria.one? || completion_criteria.none?

        errors[:base] << 'More than one method of completion'
      end

      def save
        ::Targets::CreateOrUpdateService.new(model).create_or_update(target_params)
      end

      private

      def target_group
        @target_group ||= TargetGroup.find_by(id: target_group_id)
      end

      def target_params
        {
          role: role,
          title: title,
          visibility: visibility,
          description: description,
          target_action_type: target_action_type,
          target_group_id: target_group_id,
          sort_index: sort_index,
          youtube_video_id: youtube_video_id,
          resource_ids: resource_ids,
          prerequisite_target_ids: prerequisite_target_ids,
          evaluation_criterion_ids: evaluation_criterion_ids,
          quiz: quiz,
          link_to_complete: link_to_complete,
          archived: archived,
          completion_instructions: completion_instructions
        }
      end
    end
  end
end
