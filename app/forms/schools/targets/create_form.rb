module Schools
  module Targets
    class CreateForm < Reform::Form
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

      def save
        target = Target.new(
          target_group: target_group,
          role: role,
          title: title,
          description: title,
          target_action_type: target_action_type,
          sort_index: sort_index
        )
        target.video_embed = video_embed if video_embed.present?
        target.slideshow_embed = slideshow_embed if slideshow_embed.present?
        # target.resource_ids = resource_ids if resource_ids.present?
        # target.prerequisite_target_ids = prerequisite_target_ids if prerequisite_target_ids.present?
        # target.evaluation_criterion_ids = evaluation_criterion_ids if evaluation_criterion_ids.present?
        target.save!

        # target.update(resource_ids: resource_ids) if resource_ids.present?
        # target.update(prerequisite_target_ids: prerequisite_target_ids) if prerequisite_target_ids.present?
        # target.update(evaluation_criterion_ids: evaluation_criterion_ids) if evaluation_criterion_ids.present?
        target
      end

      private

      def target_group
        @target_group ||= TargetGroup.find_by(id: target_group_id)
      end
    end
  end
end
