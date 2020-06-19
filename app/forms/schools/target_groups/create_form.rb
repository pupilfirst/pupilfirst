module Schools
  module TargetGroups
    class CreateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description
      property :milestone, validates: { presence: true }

      validate :level_exists
      validate :at_least_one_milestone_tg_exists

      def level_exists
        errors[:base] << 'Invalid level id' if model.level.blank?
      end

      def at_least_one_milestone_tg_exists
        return if model.level.target_groups.present?

        errors[:base] << 'First target group should be milestone' unless milestone
      end

      def save
        target_group = TargetGroup.create!(
          level: model.level,
          name: name,
          description: description,
          sort_index: sort_index,
          milestone: milestone
        )
        target_group
      end

      private

      def sort_index
        max_index = model.level.target_groups.maximum(:sort_index)
        max_index ? max_index + 1 : 1
      end
    end
  end
end
