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
      property :prerequisite_targets
      property :evaluation_criteria
      property :quiz
      property :link_to_complete

      validate :target_group_exists

      def target_group_exists
        errors[:base] << 'Invalid Target Group id' if target_group.blank?
      end

      def save
        target = Target.new(
          role: role,
          title: title,
          description: title,
          target_action_type: target_action_type,
          sort_index: sort_index
        )

        # video_embed.present? ?
        # link.present? ? resource.link = link : resource.file = file
        target.save!
        target
      end

      private

      def target_group
        @target_group ||= TargetGroup.find_by(id: target_group_id)
      end
    end
  end
end
