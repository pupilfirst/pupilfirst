module Types
  class SubmissionChecklistType < Types::BaseObject
    field :title, String, null: false
    field :type, String, null: false
    field :answer, String, null: true
    field :review, String, null: true
  end
end
