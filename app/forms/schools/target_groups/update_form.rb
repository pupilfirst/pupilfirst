module Schools
  module TargetGroups
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description
      property :milestone, validates: { presence: true }
      property :archived

      validate :at_least_one_milestone_tg_exists

      def at_least_one_milestone_tg_exists
        return if milestone

        return if level.target_groups.where(milestone: 'true').count >= 1

        errors[:base] << 'At least one target group must be milestone'
      end

      def save
        target_group.name = name
        target_group.milestone = milestone
        target_group.description = description
        target_group.save!

        archive_target_group(target_group, archived)

        target_group
      end

      private

      def archive_target_group(target_group, archived)
        archived ? ::TargetGroups::ArchivalService.new(target_group).archive : ::TargetGroups::ArchivalService.new(target_group).unarchive
      end

      def target_group
        @target_group ||= TargetGroup.find_by(id: id)
      end

      def level
        @level ||= target_group.level
      end
    end
  end
end
