module Types
  class CourseType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: true
    field :max_grade, Integer, null: false
    field :pass_grade, Integer, null: false
    field :grades_and_labels, [Types::GradeAndLabelType], null: false

    def grades_and_labels
      object.grade_labels.map do |grade, label|
        { grade: grade.to_i, label: label }
      end
    end
  end
end
