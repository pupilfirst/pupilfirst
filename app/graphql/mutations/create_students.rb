module Mutations
  class CreateStudents < GraphQL::Schema::Mutation
    argument :students, [Types::StudentEnrollmentInputType], required: true

    description 'Add one or more students to a course'

    field :student_ids, [ID], null: true

    def resolve(params)
      mutator = CreateStudentsMutator.new(context, params)

      student_ids = if mutator.valid?
          mutator.execute
        else
          mutator.notify_errors
          nil
        end

      { student_ids: student_ids }
    end
  end
end
