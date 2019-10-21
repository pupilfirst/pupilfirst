module Mutations
  class UpdateCourse < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :description, String, required: true
    argument :ends_at, Types::DateType, required: false
    argument :grades_and_labels, [Types::GradeAndLabelInputType], required: true
    argument :enable_leaderboard, Boolean, required: true
    argument :about, String, required: true
    argument :public_signup, Boolean, required: true

    description "Update a course."

    field :course, Types::CourseType, null: false

    def resolve(params)
      mutator = UpdateCourseMutator.new(params, context)

      if mutator.valid?
        { course: mutator.update_course }
      else
        raise "Failed with error codes: #{mutator.error_codes.to_json}"
      end
    end
  end
end
