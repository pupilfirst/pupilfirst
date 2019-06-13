module Mutations
  class AutoVerifySubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true

    description "Auto verify target"

    field :submission_details, Types::SubmissionDetails, null: true

    def resolve(params)
      mutator = AutoVerifySubmissionMutator.new(params, context)

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
