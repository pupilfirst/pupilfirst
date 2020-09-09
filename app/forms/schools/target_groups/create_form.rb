module Schools
  module TargetGroups
    class CreateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :description
      property :milestone, validates: { presence: true }

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
