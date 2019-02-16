module Schools
  module TargetGroups
    class CreateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description, validates: { presence: true, length: { maximum: 250 } }
      property :sort_index, validates: { presence: true }
      property :milestone,  validates: { presence: true }
      property :level_id, validates: { presence: true }

      validate :level_exists
      validate :at_least_one_milestone_tg_exists

      def level_exists
        errors[:base] << 'Invalid level id' if level.blank?
      end

      def at_least_one_milestone_tg_exists
        return if level.target_groups.present?

        errors[:base] << 'First target group should be milestone' unless milestone
      end

      def save
        target_group = TargetGroup.create!(
          level: level,
          name: name,
          description: description,
          sort_index: sort_index,
          milestone: milestone
        )
        target_group
      end

      private

      def level
        @level ||= Level.find_by(id: level_id)
      end
    end
  end
end
