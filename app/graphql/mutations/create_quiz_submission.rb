module Mutations
  class CreateQuizSubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :answer_ids, [ID], required: false

    description "Create quiz submission"

    field :submission, Types::SubmissionType, null: true

    def resolve(params)
      mutator = CreateQuizSubmissionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Your responses have been saved.")
        { submission: mutator.create_submission }
      else
        mutator.notify_errors
        { submission: nil }
      end
    end
  end
end
