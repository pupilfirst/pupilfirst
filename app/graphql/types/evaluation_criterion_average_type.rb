module Types
  class EvaluationCriterionAverageType < Types::BaseObject
    field :evaluation_criterion_id, ID, null: false
    field :average_grade, Float, null: false
  end
end
