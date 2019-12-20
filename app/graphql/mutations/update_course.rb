module Mutations
  class UpdateCourse < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :description, String, required: true
    argument :ends_at, Types::DateType, required: false
    argument :about, String, required: true
    argument :public_signup, Boolean, required: true
    argument :featured, Boolean, required: true

    description "Update a course."

    field :course, Types::CourseType, null: false

    def resolve(params)
      mutator = UpdateCourseMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'Course updated successfully!')
        { course: mutator.update_course }
      else
        raise "Failed with error codes: #{mutator.error_messages.to_json}"
      end
    end
  end
end
