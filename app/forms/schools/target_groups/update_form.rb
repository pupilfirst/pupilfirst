module Schools
  module TargetGroups
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description
      property :milestone, validates: { presence: true }

      validate :at_least_one_milestone_tg_exists

      def at_least_one_milestone_tg_exists
        return if milestone

        return if level.target_groups.where(milestone: 'true').count >= 1

        errors[:base] << 'At least one target group must be milestone'
      end

      def save
        target_group.name = name
        target_group.milestone = milestone
        target_group.description = description if description.present?
        target_group.save!

        target_group
      end

      private

      def target_group
        @target_group ||= TargetGroup.find_by(id: id)
      end

      def level
        @level ||= target_group.level
      end
    end
  end
end
