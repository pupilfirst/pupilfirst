module Schools
  module Targets
    class CreateForm < Reform::Form
      property :role, validates: { presence: true }
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :description, validates: { presence: true }
      property :target_action_type, validates: { presence: true }
      property :target_group_id, validates: { presence: true }
      property :sort_index, validates: { presence: true }
      property :resource_ids

      validate :target_group_exists

      def target_group_exists
        errors[:base] << 'Invalid Target Group id' if target_group.blank?
      end

      def save
        sync
        model.save!
      end

      private

      def target_group
        @target_group ||= TargetGroup.find_by(id: target_group_id)
      end
    end
  end
end
