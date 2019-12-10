module Types
  class StudentEvaluationCriterionType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :maxGrade, Integer, null: false
    field :passGrade, Integer, null: false
  end
end
