module Schools
  module TargetGroups
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description
      property :milestone, validates: { presence: true }
      property :archived
      property :level_id

      validate :at_least_one_milestone_tg_exists

      validate :should_be_a_valid_level

      def should_be_a_valid_level
        return if level.present?

        errors[:base] << "Unable to find level with id: #{level_id}"
      end

      def at_least_one_milestone_tg_exists
        return if milestone

        return if level.target_groups.where(milestone: 'true').count >= 1

        errors[:base] << 'At least one target group must be milestone'
      end

      def save
        TargetGroup.transaction do
          target_group.name = name
          target_group.milestone = milestone
          target_group.description = description

          if target_group.level_id != level_id
            target_group.sort_index = level.target_groups.maximum(:sort_index).to_i + 1
            target_group.level_id = level_id
            ::Targets::DetachFromPrerequisitesService.new(target_group.targets).execute
          end

          target_group.save!

          archive_target_group(target_group, archived)

          target_group
        end
      end

      private

      def archive_target_group(target_group, archived)
        archived ? ::TargetGroups::ArchivalService.new(target_group).archive : ::TargetGroups::ArchivalService.new(target_group).unarchive
      end

      def target_group
        @target_group ||= TargetGroup.find_by(id: id)
      end

      def level
        @level ||= target_group.school.levels.find_by(id: level_id)
      end
    end
  end
end
