module Mutations
  class CreateSubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :description, String, required: true
    argument :links, [String], required: true
    argument :file_ids, [ID], required: true

    description "Create a new submission for a target"

    field :submission, Types::SubmissionType, null: true

    def resolve(params)
      mutator = CreateSubmissionMutator.new(params, context)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Your submission has been queued for review.")
        { submission: mutator.create_submission }
      else
        mutator.notify_errors
        { submission: nil }
      end
    end
  end
end
