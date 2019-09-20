module Types
  class GradeType < Types::BaseObject
    field :evaluation_criterion_id, ID, null: false
    field :grade, Int, null: false
  end
end
