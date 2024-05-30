module Types
  class TargetInfoType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :milestone_number, Integer, null: true

    def milestone_number
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |target_ids, loader|
          Assignment
            .where(target_id: target_ids)
            .each do |assignment|
              loader.call(assignment.target_id, assignment.milestone_number)
            end
        end
    end
  end
end
