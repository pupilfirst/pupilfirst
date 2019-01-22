module Schools
  module TargetGroups
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description, validates: { presence: true, length: { maximum: 250 } }
      property :sort_index, validates: { presence: true }
      property :milestone,  validates: { presence: true }

      validate :at_least_one_milestone_tg_exists

      def at_least_one_milestone_tg_exists
        return unless milestone.to_i.zero?

        return unless level.target_groups.where(milestone: 'true').count.zero?

        errors[:base] << 'At least one target group must be milestone'
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
