module Types
  class ReviewerDetailInfoType < Types::BaseObject
    field :name, String, null: false
    field :assigned_at, GraphQL::Types::ISO8601DateTime, null: false

    def name
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(reviewer: :user)
            .where(id: submission_ids)
            .each do |submission|
              loader.call(submission.id, submission.reviewer&.user&.name)
            end
        end
    end

    def assigned_at
      object.reviewer_assigned_at
    end
  end
end
