module Mutations
  class CreateGrading < GraphQL::Schema::Mutation
    argument :submission_id, ID, required: true
    argument :grades, [Types::GradeInputType], required: true
    argument :feedback, String, required: false
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :note, String, required: false

    description "Create grading for submission"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateGradingMutator.new(context, params)

      if mutator.valid?
        mutator.grade
        mutator.notify(:success, "Grades Recorded", "The submission has been marked as reviewed.")
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
