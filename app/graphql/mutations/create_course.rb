module Mutations
  class CreateCourse < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :description, String, required: true
    argument :max_grade, Integer, required: true
    argument :pass_grade, Integer, required: true
    argument :ends_at, Types::DateType, required: false
    argument :grades_and_labels, [Types::GradeAndLabelInputType], required: true
    argument :enable_leaderboard, Boolean, required: true
    argument :about, String, required: true
    argument :public_signup, Boolean, required: true

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
