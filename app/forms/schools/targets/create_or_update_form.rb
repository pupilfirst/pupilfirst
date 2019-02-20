module Schools
  module Targets
    class CreateOrUpdateForm < Reform::Form
      property :role, validates: { presence: true }
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :description, validates: { presence: true }
      property :target_action_type, validates: { presence: true }
      property :target_group_id, validates: { presence: true }
      property :sort_index
      property :video_embed
      property :slideshow_embed
      property :resource_ids
      property :prerequisite_target_ids
      property :evaluation_criterion_ids
      property :quiz
      property :link_to_complete

      validate :target_group_exists

      def target_group_exists
        errors[:base] << 'Invalid Target Group id' if target_group.blank?
      end

      # validate :only_one_method_of_completion

      def save(target_params)
        ::Targets::CreateOrUpdateService.new(model).create_or_update(target_params)
      end

      private

      def target_group
        @target_group ||= TargetGroup.find_by(id: target_group_id)
      end
    end
  end
end
