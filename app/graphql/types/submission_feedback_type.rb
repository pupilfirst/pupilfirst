module Types
  class SubmissionFeedbackType < Types::BaseObject
    field :id, ID, null: false
    field :coach_id, String, null: false
    field :feedback, String, null: false
    field :created_at, String, null: false
  end
end
