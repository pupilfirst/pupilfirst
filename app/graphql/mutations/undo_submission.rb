module Mutations
  class UndoSubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true

    description "Delete the last submission for a target"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UndoSubmissionMutator.new(context, params)

      if mutator.valid?
        mutator.undo_submission
        { success: true }
      else
        { success: false }
      end
    end
  end
end
