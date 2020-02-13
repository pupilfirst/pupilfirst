module Types
  class SubmissionChecklistType < Types::BaseObject
    field :title, String, null: false
    field :kind, String, null: false
    field :status, String, null: false
    field :result, String, null: true
  end
end
