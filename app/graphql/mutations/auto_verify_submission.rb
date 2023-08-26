module Mutations
  class AutoVerifySubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true

    description "Auto verify target"

    field :submission, Types::SubmissionType, null: true

    def resolve(params)
      mutator = AutoVerifySubmissionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, I18n.t('shared.notifications.done_exclamation'), I18n.t('mutations.auto_verify_submission.success_notification'))
        { submission: mutator.create_submission }
      else
        mutator.notify_errors
        { submission: nil }
      end
    end
  end
end
