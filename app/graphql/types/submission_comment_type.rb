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
  end
end
