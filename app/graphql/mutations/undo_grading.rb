module Mutations
  class UndoGrading < GraphQL::Schema::Mutation
    argument :submission_id, ID, required: true

    description "Delete grading for the submission"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UndoGradingMutator.new(context, params)

      if mutator.valid?
        mutator.undo_grading
        mutator.notify(:success, "Grades Removed", "The submission is now pending review.")
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
