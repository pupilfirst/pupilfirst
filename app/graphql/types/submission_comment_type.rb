module Types
  class SubmissionCommentType < Types::BaseObject
    field :id, ID, null: false
    field :submission_id, ID, null: false
    field :comment, String, null: false
    field :reactions, [ReactionType], null: false
    field :user_name, String, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
