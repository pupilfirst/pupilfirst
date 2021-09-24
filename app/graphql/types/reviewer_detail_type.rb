module Types
  class ReviewerDetailType < Types::BaseObject
    field :user, Types::UserProxyType, null: false
    field :assigned_at, GraphQL::Types::ISO8601DateTime, null: false

    def user
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(reviewer: :user)
            .where(id: submission_ids)
            .each do |submission|
              loader.call(submission.id, submission.reviewer)
            end
        end
    end

    def assigned_at
      object.reviewer_assigned_at
    end
  end
end
