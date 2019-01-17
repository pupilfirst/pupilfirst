module Schools
  module Targets
    class CreateForm < Reform::Form
      property :role, validates: { presence: true }
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :description, validates: { presence: true }
      property :target_action_type, validates: { presence: true }
      property :target_group_id, validates: { presence: true }
      property :sort_index, validates: { presence: true }
      # validate :level_exists
      # validate :at_least_one_milestone_tg_exists

      def save
        sync
        model.save!
      end

      private

      def level_exists
        errors[:base] << 'Invalid level id' if level.blank?
      end

      def level
        @level ||= Level.find_by(id: level_id)
      end

      def at_least_one_milestone_tg_exists
        return if level.target_groups.present?

        errors[:base] << 'First target group should be milestone' if milestone.to_i.zero?
      end
    end
  end
end
