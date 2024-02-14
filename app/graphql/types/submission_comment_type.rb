module Types
  class SubmissionCommentType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: false
    field :submission_id, ID, null: false
    field :comment, String, null: false
    field :reactions, [ReactionType], null: false
    field :moderation_reports, [ModerationReportType], null: false
    field :user, UserType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :hidden_at, GraphQL::Types::ISO8601DateTime, null: true
    field :hidden_by_id, ID, null: true

    def submission_id
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |comment_ids, loader|
          SubmissionComment
            .where(id: comment_ids)
            .each do |comment|
              loader.call(comment.id, comment.timeline_event_id)
            end
        end
    end
  end
end
