module Mutations
  class CreateQuizSubmission < GraphQL::Schema::Mutation
    argument :target_id, String, required: true
    argument :answer_ids, [String], required: false

    description "Create quiz submission"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateQuizSubmissionMutator.new(params, context)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Your Submission has been recorded")
        { success: mutator.create_submission }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
