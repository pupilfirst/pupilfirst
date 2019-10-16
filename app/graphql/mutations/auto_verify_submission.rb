module Mutations
  class AutoVerifySubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true

    description "Auto verify target"

    field :submission, Types::SubmissionType, null: true

    def resolve(params)
      mutator = AutoVerifySubmissionMutator.new(params, context)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Your Submission has been recorded")
        { submission: mutator.create_submission }
      else
        mutator.notify_errors
        { submission: nil }
      end
    end
  end
end
