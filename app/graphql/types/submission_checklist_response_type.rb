module Types
  class SubmissionChecklistResponseType < Types::BaseObject
    field :title, String, null: false
    field :action, String, null: false
    field :optional, Boolean, null: false
    field :response, String, null: true
    field :review, String, null: true
  end
end
