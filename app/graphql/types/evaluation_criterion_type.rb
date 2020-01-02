module Types
  class EvaluationCriterionType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :maxGrade, Integer, null: false
    field :passGrade, Integer, null: false
    field :grades_and_labels, [Types::GradeAndLabelType], null: false

    def grades_and_labels
      object['grade_labels'].map do |grade, label|
        { grade: grade.to_i, label: label }
      end
    end
  end
end
