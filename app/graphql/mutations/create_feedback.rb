module Mutations
  class CreateFeedback < GraphQL::Schema::Mutation
    argument :submission_id, ID, required: true
    argument :feedback, String, required: true

    description "Create feedback for submission"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateFeedbackMutator.new(params, context)

      if mutator.valid?
        mutator.create_feedback
        mutator.notify(:success, "Done!", "Your feedback recorded successfully")
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
