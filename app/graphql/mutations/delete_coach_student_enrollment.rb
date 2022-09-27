module Mutations
  class DeleteCoachStudentEnrollment < GraphQL::Schema::Mutation
    argument :coach_id, ID, required: true
    argument :student_id, ID, required: true

    description 'Deletes an assigned student for a coach'

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteCoachStudentEnrollmentMutator.new(context, params)

      if mutator.valid?
        mutator.delete_coach_student_enrollment
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
