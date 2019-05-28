module Mutations
  class CreateTarget < GraphQL::Schema::Mutation
    argument :title, String, required: true
    argument :max_grade, Integer, required: true
    argument :pass_grade, Integer, required: true
    argument :ends_at, String, required: true
    argument :grades_and_labels, [Types::GradeAndLabelInputType], required: true

    description "Create a new course."

    field :course, Types::CourseType, null: false

    def resolve(params)
      mutator = CreateCourseMutator.new(params, context)

      if mutator.valid?
        { course: mutator.create_course, errors: [] }
      else
        { course: nil, errors: mutator.error_codes }
      end
    end
  end
end
