module Mutations
  class CreateGrading < GraphQL::Schema::Mutation
    argument :submission_id, ID, required: true
    argument :grades, [Types::GradeInputType], required: true
    argument :feedback, String, required: false

    description "Create grading for submission"

    field :success, Boolean, null: true

    def resolve(params)
      mutator = CreateGradingMutator.new(params, context)

      if mutator.valid?
        mutator.grade
        mutator.notify(:success, "Grading Recorded", "Submission reviewed and moved to completed")
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
