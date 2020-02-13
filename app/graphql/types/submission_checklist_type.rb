module Types
  class SubmissionChecklistType < Types::BaseObject
    field :title, String, null: false
    field :kind, String, null: false
    field :result, String, null: true
    field :status, String, null: true
  end
end
