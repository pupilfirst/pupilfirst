module Mutations
  class CreateSubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :file_ids, [ID], required: true

    description "Create a new submission for a target"

    field :submission, Types::SubmissionType, null: true
    field :level_up_eligibility, Types::LevelUpEligibility, null: true

    def resolve(params)
      mutator = CreateSubmissionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Your submission has been queued for review.")
        { submission: mutator.create_submission, level_up_eligibility: mutator.level_up_eligibility }
      else
        mutator.notify_errors
        { submission: nil, level_up_eligibility: nil }
      end
    end
  end
end
