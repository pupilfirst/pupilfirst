module Mutations
  class CreateCourse < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :description, String, required: true
    argument :ends_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :about, String, required: true
    argument :public_signup, Boolean, required: true
    argument :featured, Boolean, required: true
    argument :progression_behavior, Types::ProgressionBehaviorType, required: true
    argument :progression_limit, Integer, required: false

    description "Create a new course."

    field :course, Types::CourseType, null: true

    def resolve(params)
      mutator = CreateCourseMutator.new(context, params)

      course = if mutator.valid?
        mutator.notify(:success, 'Done!', 'Course created successfully!')
        mutator.create_course
      else
        mutator.notify_errors
        nil
      end

      { course: course }
    end
  end
end
