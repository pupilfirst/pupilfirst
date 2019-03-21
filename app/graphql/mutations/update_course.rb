module Mutations
  class UpdateCourse < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :ends_at, String, required: true
    argument :grades_and_labels, [Types::GradeAndLabelInputType], required: true

    description "Update a course."

    field :course, Types::CourseType, null: false

    def self.accessible?(context)
      context[:current_user].present?
    end

    def resolve(params)
      mutator = UpdateCourseMutator.new(params, context)

      if mutator.valid?
        { course: mutator.update_course, errors: [] }
      else
        { course: nil, errors: mutator.error_codes }
      end
    end
  end
end
