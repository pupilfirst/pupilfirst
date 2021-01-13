module Mutations
  class CreateStudents < GraphQL::Schema::Mutation
    argument :course_id, ID, required: true
    argument :students, [Types::StudentEnrollmentInputType], required: true
    argument :notify_students, Boolean, required: true

    description 'Add one or more students to a course'

    field :student_ids, [ID], null: true

    def resolve(params)
      mutator = CreateStudentsMutator.new(context, params)

      student_ids = if mutator.valid?
          mutator.create_students
        else
          mutator.notify_errors
          nil
        end

      { student_ids: student_ids }
    end
  end
end
