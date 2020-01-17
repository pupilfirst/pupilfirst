module Mutations
  class CreateCourse < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :description, String, required: true
    argument :ends_at, Types::DateType, required: false
    argument :about, String, required: true
    argument :public_signup, Boolean, required: true
    argument :featured, Boolean, required: true

    description "Create a new course."

    field :course, Types::CourseType, null: false

    def resolve(params)
      mutator = CreateCourseMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'Course created successfully!')
        { course: mutator.create_course, errors: [] }
      else
        { course: nil, errors: mutator.error_messages }
      end
    end
  end
end
