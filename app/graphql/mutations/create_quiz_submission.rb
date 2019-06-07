module Mutations
  class CreateQuizSubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :answer_ids, [ID], required: false

    description "Create quiz submission"

    field :submission_details, Types::SubmissionDetails, null: true

    def resolve(params)
      mutator = CreateQuizSubmissionMutator.new(params, context)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Your Submission has been recorded")
        { submission_details: mutator.create_submission }
      else
        mutator.notify_errors
        { submission_details: nil }
      end
    end
  end
end
