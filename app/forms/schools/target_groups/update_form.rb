module Schools
  module TargetGroups
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description
      property :archived
      property :level_id

      validate :should_be_a_valid_level

      def should_be_a_valid_level
        return if level.present?

        errors.add(:base, "Unable to find level with id: #{level_id}")
      end

      def save
        TargetGroup.transaction do
          model.name = name
          model.description = description

          if model.level_id != level_id.to_i
            model.sort_index = level.target_groups.maximum(:sort_index).to_i + 1
            model.level_id = level_id
          end

          model.save!

          archive_target_group(model, archived)

          model
        end
      end

      private

      def archive_target_group(target_group, archived)
        if archived
          ::TargetGroups::ArchivalService.new(target_group).archive
        else
          ::TargetGroups::ArchivalService.new(target_group).unarchive
        end
      end

      def level
        @level ||= model.course.levels.find_by(id: level_id)
      end
    end
  end
end
