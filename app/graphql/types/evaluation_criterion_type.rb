module Types
  class EvaluationCriterionType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :max_grade, Integer, null: false
    field :pass_grade, Integer, null: false
    field :grade_labels, [Types::GradeAndLabelType], null: false
  end
end
