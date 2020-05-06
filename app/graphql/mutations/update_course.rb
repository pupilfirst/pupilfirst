module Mutations
  class UpdateCourse < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :description, String, required: true
    argument :ends_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :about, String, required: true
    argument :public_signup, Boolean, required: true
    argument :featured, Boolean, required: true
    argument :progression_behavior, Types::ProgressionBehaviorType, required: true
    argument :progression_limit, Integer, required: false

    description "Update a course."

    field :course, Types::CourseType, null: true

    def resolve(params)
      mutator = UpdateCourseMutator.new(context, params)

      course = if mutator.valid?
        mutator.notify(:success, 'Done!', 'Course updated successfully!')
        mutator.update_course
      else
        mutator.notify_errors
        nil
      end

      { course: course }
    end
  end
end
