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
          model.name = name
          model.milestone = milestone
          model.description = description

          if model.level_id != level_id.to_i
            model.sort_index = level.target_groups.maximum(:sort_index).to_i + 1
            model.level_id = level_id
            ::Targets::DetachFromPrerequisitesService.new(model.targets).execute
          end

          model.save!

          archive_target_group(model, archived)

          model
        end
      end

      private

      def archive_target_group(target_group, archived)
        archived ? ::TargetGroups::ArchivalService.new(target_group).archive : ::TargetGroups::ArchivalService.new(target_group).unarchive
      end

      def level
        @level ||= model.course.levels.find_by(id: level_id)
      end
    end
  end
end
