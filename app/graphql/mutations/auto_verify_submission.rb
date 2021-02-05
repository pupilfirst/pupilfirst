module Mutations
  class AutoVerifySubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true

    description "Auto verify target"

    field :submission, Types::SubmissionType, null: true
    field :level_up_eligibility, Types::LevelUpEligibility, null: true

    def resolve(params)
      mutator = AutoVerifySubmissionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, I18n.t('shared.done_exclamation'), I18n.t('mutations.auto_verify_submission.success_notification'))
        { submission: mutator.create_submission, level_up_eligibility: mutator.level_up_eligibility }
      else
        mutator.notify_errors
        { submission: nil, level_up_eligibility: nil }
      end
    end
  end
end
