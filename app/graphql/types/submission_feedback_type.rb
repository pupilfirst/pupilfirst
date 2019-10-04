module Types
  class SubmissionFeedbackType < Types::BaseObject
    field :id, ID, null: false
    field :value, String, null: false
    field :created_at, String, null: false
    field :coach_name, String, null: false
    field :coach_avatar_url, String, null: false
    field :coach_title, String, null: true
  end
end
