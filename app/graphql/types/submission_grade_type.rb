module Types
  class SubmissionGradeType < Types::BaseObject
    field :id, ID, null: false
    field :evaluation_criterion_id, ID, null: false
    field :grade, Int, null: false
  end
end
